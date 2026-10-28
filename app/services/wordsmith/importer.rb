# Builds the wordsmith_entries table from three offline, open-licensed sources:
#
#   * WordNet 3.1 (Princeton)            -> definitions, examples, synonyms, antonyms
#   * CMU Pronouncing Dictionary         -> pronunciations, syllables, rhymes
#   * Moby Thesaurus (public domain)     -> broader "related words"
#
# The importer only reads local files; Wordsmith::Sources handles fetching the
# pinned packages. Nothing here (or in Wordsmith::Lookup) touches the network
# at request time.
module Wordsmith
  class Importer
    WORDNET_FILES = { 'n' => 'noun', 'v' => 'verb', 'a' => 'adj', 'r' => 'adv' }.freeze
    POS_NAMES     = { 'n' => 'noun', 'v' => 'verb', 'a' => 'adjective', 's' => 'adjective', 'r' => 'adverb' }.freeze

    # WordNet pointer types we use: antonyms and "similar to" (adjective clusters).
    USED_POINTERS = %w(! &).freeze

    MAX_SENSES_PER_POS = 10
    MAX_EXAMPLES       = 2
    MAX_SIMILAR        = 8
    MAX_RELATED        = 120
    BATCH_SIZE         = 1_000

    COMMON_WORD_FORMAT = /\A[a-z]+(?:['-][a-z]+)*\z/

    # Rough sound classes for consonants. Near rhymes keep the vowels but only
    # the class of each consonant, so "grief" (IY F) near-rhymes with "sleeve"
    # (IY V) and "peace" (IY S) but not "beam" (IY M).
    CONSONANT_CLASSES = {
      'P' => 'stop', 'B' => 'stop', 'T' => 'stop', 'D' => 'stop', 'K' => 'stop', 'G' => 'stop',
      'F' => 'fric', 'V' => 'fric', 'TH' => 'fric', 'DH' => 'fric', 'S' => 'fric', 'Z' => 'fric', 'SH' => 'fric', 'ZH' => 'fric', 'HH' => 'fric',
      'CH' => 'affr', 'JH' => 'affr', 'M' => 'nasal', 'N' => 'nasal', 'NG' => 'nasal',
      'L' => 'liquid', 'R' => 'liquid', 'W' => 'glide', 'Y' => 'glide'
    }.freeze

    attr_reader :wordnet_dir, :cmu_file, :moby_file

    def initialize(wordnet_dir:, cmu_file:, moby_file:, logger: Rails.logger)
      @wordnet_dir = wordnet_dir
      @cmu_file    = cmu_file
      @moby_file   = moby_file
      @logger      = logger
    end

    def import!
      usage                            = load_usage_counts
      related, vocabulary, appearances = load_moby(usage)
      pronunciations                   = load_pronunciations

      synsets = load_synsets
      senses  = load_senses(synsets)

      # Words either source spells in lowercase somewhere, i.e. not only as a
      # proper noun ("Japan") or abbreviation ("AMD").
      synsets.each_value { |synset| synset[:words].each { |w| vocabulary << w if w == w.downcase } }
      synsets = nil

      words = (senses.keys + pronunciations.keys + related.keys).uniq
      log "Writing #{words.size} entries"

      WordsmithEntry.transaction do
        WordsmithEntry.delete_all

        words.each_slice(BATCH_SIZE) do |batch|
          rows = batch.map do |word|
            phones = pronunciations[word]
            rhyme_key, near_rhyme_key = Importer.rhyme_keys(phones)
            frequency = usage[word] + appearances[word]

            {
              word:           word,
              senses:         senses[word],
              related:        related[word]&.to_json,
              pronunciation:  phones,
              syllables:      phones && phones.scan(/\d/).size,
              rhyme_key:      rhyme_key,
              near_rhyme_key: near_rhyme_key,
              frequency:      frequency,
              common:         frequency.positive? && Importer.common_word?(word, phones, vocabulary)
            }
          end

          WordsmithEntry.insert_all(rows)
        end
      end

      words.size
    end

    # Whether a word is ordinary enough to suggest as a rhyme. The CMU
    # dictionary is mostly names and acronyms; acronyms read letter by letter
    # carry several primary stresses ("AMD" -> "EY1 EH1 M D IY1").
    def self.common_word?(word, phones, vocabulary)
      word.match?(COMMON_WORD_FORMAT) &&
        (word.length > 1 || %w(a i o).include?(word)) &&
        word.match?(/[aeiouy]/) &&
        vocabulary.include?(word) &&
        phones.to_s.count('1') <= 1
    end

    # Perfect rhymes share every phone from the last stressed vowel onward
    # ("grief" -> "IY F"); near rhymes share the vowels and the kinds of
    # consonants from that point ("IY fric").
    def self.rhyme_keys(phones)
      return [nil, nil] if phones.blank?

      phones = phones.split
      vowel_indexes = phones.each_index.select { |i| phones[i] =~ /\d/ }
      return [nil, nil] if vowel_indexes.empty?

      stressed = vowel_indexes.reverse.find { |i| phones[i].end_with?('1') } ||
                 vowel_indexes.reverse.find { |i| phones[i].end_with?('2') } ||
                 vowel_indexes.last

      tail = phones[stressed..].map { |phone| phone.delete('0-9') }
      [tail.join(' '), tail.map { |phone| CONSONANT_CLASSES[phone] || phone }.join(' ')]
    end

    private

    def log(message)
      @logger.info("[Wordsmith] #{message}")
    end

    # How often each lemma appears in WordNet's sense-tagged corpus, summed
    # across its senses ("time" is tagged hundreds of times, "ca" never). Sparse,
    # but a good signal of everyday words; Moby list appearances fill in the rest.
    def load_usage_counts
      counts = Hash.new(0)

      File.foreach(File.join(wordnet_dir, 'index.sense')) do |line|
        sense_key, _offset, _sense_number, tag_count = line.split(' ')
        counts[sense_key[/\A[^%]+/].tr('_', ' ')] += tag_count.to_i
      end

      log "Loaded usage counts for #{counts.size} WordNet lemmas"
      counts
    end

    # Returns { "n00001740" => { type:, words: [...], pointers: [...], gloss: } }
    def load_synsets
      synsets = {}

      WORDNET_FILES.each do |file_pos, name|
        File.foreach(File.join(wordnet_dir, "data.#{name}")) do |line|
          next if line.start_with?(' ') # license header

          head, gloss = line.split(' | ', 2)
          fields = head.split(' ')

          offset     = fields[0]
          type       = fields[2]
          word_count = fields[3].to_i(16)
          words      = (0...word_count).map { |i| clean_wordnet_word(fields[4 + i * 2]) }

          pointer_start = 4 + word_count * 2
          pointer_count = fields[pointer_start].to_i
          pointers = (0...pointer_count).filter_map do |i|
            symbol, target_offset, target_pos, source_target = fields[pointer_start + 1 + i * 4, 4]
            next unless USED_POINTERS.include?(symbol)

            {
              symbol: symbol,
              key:    synset_key(target_pos, target_offset),
              source: source_target[0, 2].to_i(16),
              target: source_target[2, 2].to_i(16)
            }
          end

          synsets[synset_key(file_pos, offset)] = { type: type, words: words, pointers: pointers, gloss: gloss.to_s.strip }
        end
      end

      log "Loaded #{synsets.size} WordNet synsets"
      synsets
    end

    # Returns { "constantly" => '[{"pos":..,"definition":..,"examples":..,"synonyms":..,"antonyms":..,"similar":..}]' }
    def load_senses(synsets)
      by_word = Hash.new { |hash, key| hash[key] = {} }

      WORDNET_FILES.each do |file_pos, name|
        File.foreach(File.join(wordnet_dir, "index.#{name}")) do |line|
          next if line.start_with?(' ')

          fields = line.split(' ')
          lemma         = fields[0].tr('_', ' ')
          synset_count  = fields[2].to_i
          pointer_count = fields[3].to_i
          offsets       = fields[(4 + pointer_count + 2), synset_count]

          by_word[lemma][file_pos] = {
            count:  synset_count,
            # Kept as JSON strings: ~150k lemmas of nested hashes would use far more memory.
            senses: offsets.first(MAX_SENSES_PER_POS).filter_map { |offset| build_sense(lemma, synsets, synset_key(file_pos, offset))&.to_json }
          }
        end
      end

      # Show the part of speech with the most meanings first ("run" is mostly a verb).
      senses = by_word.transform_values do |by_pos|
        "[#{by_pos.values.sort_by { |pos| -pos[:count] }.flat_map { |pos| pos[:senses] }.join(',')}]"
      end

      log "Built senses for #{senses.size} WordNet lemmas"
      senses
    end

    def build_sense(lemma, synsets, key)
      synset = synsets[key]
      return unless synset

      word_index = synset[:words].index { |w| w.casecmp?(lemma) }.to_i + 1
      definition, examples = parse_gloss(synset[:gloss])

      antonyms = pointer_words(synsets, synset, '!', word_index)
      if antonyms.empty? && synset[:type] == 's'
        # Satellite adjectives ("vehement") borrow antonyms from their head ("intense" -> "mild").
        head = synset[:pointers].find { |p| p[:symbol] == '&' }
        antonyms = pointer_words(synsets, synsets[head[:key]], '!', 0) if head && synsets[head[:key]]
      end

      {
        pos:        POS_NAMES[synset[:type]],
        definition: definition,
        examples:   examples.first(MAX_EXAMPLES),
        synonyms:   synset[:words].reject { |w| w.casecmp?(lemma) }.uniq,
        antonyms:   antonyms,
        similar:    pointer_words(synsets, synset, '&', 0).reject { |w| w.casecmp?(lemma) }.first(MAX_SIMILAR)
      }
    end

    # Words reachable from a synset through pointers of the given type. Lexical
    # pointers (antonyms) only apply to one word in the synset, so they're
    # filtered to the pointers whose source is the lemma being looked up.
    def pointer_words(synsets, synset, symbol, word_index)
      synset[:pointers].select { |p| p[:symbol] == symbol }.flat_map do |pointer|
        next [] if word_index.positive? && pointer[:source].positive? && pointer[:source] != word_index

        target = synsets[pointer[:key]]
        next [] unless target

        pointer[:target].positive? ? [target[:words][pointer[:target] - 1]] : target[:words]
      end.compact.uniq
    end

    def parse_gloss(gloss)
      examples   = gloss.scan(/"([^"]+)"/).flatten.map(&:strip)
      definition = gloss.split('"').first.to_s.strip.sub(/;\z/, '').strip
      [definition, examples]
    end

    def clean_wordnet_word(word)
      word.sub(/\((?:a|p|ip)\)\z/, '').tr('_', ' ')
    end

    def synset_key(pos, offset)
      "#{pos == 's' ? 'a' : pos}#{offset}"
    end

    # The CMU package ships as a JS object literal: `  "word": "W ER1 D",`.
    # Alternate pronunciations ("read(2)") are skipped in favor of the primary one.
    def load_pronunciations
      pronunciations = {}

      File.foreach(cmu_file) do |line|
        match = line.match(/\A\s*"((?:[^"\\]|\\.)+)": "([A-Z0-9 ]+)"/)
        next unless match

        word = match[1].gsub(/\\(.)/, '\1')
        next if word.end_with?(')')

        pronunciations[word.downcase] ||= match[2]
      end

      log "Loaded #{pronunciations.size} CMU pronunciations"
      pronunciations
    end

    # Each Moby line is "root,related,related,...". Returns:
    #
    #   * the related lists, keyed by root
    #   * every lowercase word Moby knows (used to tell real words apart from
    #     the names and acronyms that fill the CMU dictionary)
    #   * how many lists each word appears in (a proxy for how common it is)
    #
    # Moby lists are alphabetical and can run to thousands of words, so each
    # one is re-sorted and capped. Mutual entries come first: if "grief" lists
    # "anguish" and "anguish" lists "grief", they're close in meaning. Then
    # words that are common but specific: corpus usage divided by how many
    # lists a word is in, since vague words like "take" appear in hundreds.
    def load_moby(usage)
      appearances = Hash.new(0)
      lists = {} # root -> ",its,whole,list," for cheap membership checks

      File.foreach(moby_file) do |line|
        words = line.strip.downcase.split(',').map(&:strip)
        words.each { |word| appearances[word] += 1 }
        lists[words.first] = ",#{words.join(',')}," if words.first
      end

      related    = {}
      vocabulary = Set.new

      File.foreach(moby_file) do |line|
        root, *words = line.strip.split(',').map(&:strip).reject(&:empty?)
        next unless root

        root = root.downcase
        vocabulary << root
        words.each { |w| vocabulary << w if w == w.downcase }

        words = (related[root] || []) + words.reject { |w| w.casecmp?(root) }
        related[root] = words.uniq.each_with_index
                             .sort_by do |w, i|
                               key = w.downcase
                               mutual = lists[key]&.include?(",#{root},")
                               specificity = (usage[key] + 1).fdiv(appearances[key] + 1)
                               [w == key ? 0 : 1, mutual ? 0 : 1, w.include?(' ') ? 1 : 0, -specificity, i]
                             end
                             .map(&:first)
                             .first(MAX_RELATED)
      end

      log "Loaded #{related.size} Moby thesaurus roots"
      [related, vocabulary, appearances]
    end
  end
end
