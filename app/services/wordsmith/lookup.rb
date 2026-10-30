# Answers a Wordsmith panel lookup from the local wordsmith_entries table.
#
#   Wordsmith::Lookup.new("Running").call
#   # => { found: true, word: "run", query: "running", senses: [...], rhymes: [...], ... }
module Wordsmith
  class Lookup
    MAX_QUERY_LENGTH  = 60
    MAX_RHYMES        = 150
    MAX_NEAR_RHYMES   = 60

    # WordNet's base-form rules ("morphy"), tried in order when a word isn't
    # found as typed: "cities" -> "city", "running" -> "runn" -> "run".
    SUFFIX_RULES = [
      ['ies', 'y'], ['ses', 's'], ['xes', 'x'], ['zes', 'z'], ['ches', 'ch'], ['shes', 'sh'],
      ['men', 'man'], ['es', 'e'], ['es', ''], ['s', ''],
      ['ied', 'y'], ['ed', 'e'], ['ed', ''], ['ing', 'e'], ['ing', ''],
      ['est', 'e'], ['est', ''], ['er', 'e'], ['er', ''], ['ly', '']
    ].freeze

    IRREGULAR_FORMS = {
      'ran' => 'run', 'went' => 'go', 'gone' => 'go', 'was' => 'be', 'were' => 'be', 'been' => 'be', 'is' => 'be', 'am' => 'be', 'are' => 'be',
      'had' => 'have', 'has' => 'have', 'did' => 'do', 'done' => 'do', 'does' => 'do', 'said' => 'say', 'made' => 'make',
      'took' => 'take', 'taken' => 'take', 'came' => 'come', 'saw' => 'see', 'seen' => 'see', 'knew' => 'know', 'known' => 'know',
      'got' => 'get', 'gotten' => 'get', 'gave' => 'give', 'given' => 'give', 'found' => 'find', 'thought' => 'think',
      'told' => 'tell', 'felt' => 'feel', 'brought' => 'bring', 'began' => 'begin', 'begun' => 'begin', 'kept' => 'keep',
      'held' => 'hold', 'stood' => 'stand', 'heard' => 'hear', 'meant' => 'mean', 'met' => 'meet', 'paid' => 'pay',
      'sat' => 'sit', 'spoke' => 'speak', 'spoken' => 'speak', 'led' => 'lead', 'grew' => 'grow', 'grown' => 'grow',
      'lost' => 'lose', 'fell' => 'fall', 'fallen' => 'fall', 'sent' => 'send', 'built' => 'build', 'understood' => 'understand',
      'drew' => 'draw', 'drawn' => 'draw', 'broke' => 'break', 'broken' => 'break', 'spent' => 'spend', 'rose' => 'rise',
      'risen' => 'rise', 'drove' => 'drive', 'driven' => 'drive', 'bought' => 'buy', 'wore' => 'wear', 'worn' => 'wear',
      'chose' => 'choose', 'chosen' => 'choose', 'sought' => 'seek', 'threw' => 'throw', 'thrown' => 'throw',
      'caught' => 'catch', 'fought' => 'fight', 'taught' => 'teach', 'slept' => 'sleep', 'wrote' => 'write',
      'written' => 'write', 'ate' => 'eat', 'eaten' => 'eat', 'flew' => 'fly', 'flown' => 'fly', 'hid' => 'hide',
      'hidden' => 'hide', 'shook' => 'shake', 'shaken' => 'shake', 'swam' => 'swim', 'sang' => 'sing', 'sung' => 'sing',
      'rang' => 'ring', 'rung' => 'ring', 'struck' => 'strike', 'stole' => 'steal', 'stolen' => 'steal', 'froze' => 'freeze',
      'frozen' => 'freeze', 'forgot' => 'forget', 'forgotten' => 'forget', 'bit' => 'bite', 'bitten' => 'bite',
      'fled' => 'flee', 'slid' => 'slide', 'swore' => 'swear', 'sworn' => 'swear', 'tore' => 'tear', 'torn' => 'tear',
      'woke' => 'wake', 'woken' => 'wake', 'wept' => 'weep', 'crept' => 'creep', 'knelt' => 'kneel', 'dealt' => 'deal',
      'dreamt' => 'dream', 'leapt' => 'leap', 'clung' => 'cling', 'flung' => 'fling', 'stung' => 'sting', 'swung' => 'swing',
      'children' => 'child', 'feet' => 'foot', 'teeth' => 'tooth', 'mice' => 'mouse', 'geese' => 'goose', 'people' => 'person',
      'better' => 'good', 'best' => 'good', 'worse' => 'bad', 'worst' => 'bad'
    }.freeze

    ARPABET_IPA = {
      'AA' => 'ɑ', 'AE' => 'æ', 'AH' => 'ʌ', 'AO' => 'ɔ', 'AW' => 'aʊ', 'AY' => 'aɪ', 'B' => 'b', 'CH' => 'tʃ', 'D' => 'd',
      'DH' => 'ð', 'EH' => 'ɛ', 'ER' => 'ɝ', 'EY' => 'eɪ', 'F' => 'f', 'G' => 'ɡ', 'HH' => 'h', 'IH' => 'ɪ', 'IY' => 'i',
      'JH' => 'dʒ', 'K' => 'k', 'L' => 'l', 'M' => 'm', 'N' => 'n', 'NG' => 'ŋ', 'OW' => 'oʊ', 'OY' => 'ɔɪ', 'P' => 'p',
      'R' => 'ɹ', 'S' => 's', 'SH' => 'ʃ', 'T' => 't', 'TH' => 'θ', 'UH' => 'ʊ', 'UW' => 'u', 'V' => 'v', 'W' => 'w',
      'Y' => 'j', 'Z' => 'z', 'ZH' => 'ʒ'
    }.freeze
    UNSTRESSED_IPA = { 'AH' => 'ə', 'ER' => 'ɚ' }.freeze

    # Consonant clusters English allows at the start of a syllable; used to put
    # IPA stress marks before "spl" in "explain" rather than just before "l".
    ONSETS = %w(
      P_L P_R B_L B_R T_R D_R K_L K_R G_L G_R F_L F_R TH_R SH_R S_P S_T S_K S_M S_N S_L S_W T_W D_W K_W G_W TH_W
      P_Y B_Y F_Y K_Y M_Y HH_Y V_Y S_P_L S_P_R S_T_R S_K_R S_K_W S_P_Y S_K_Y
    ).map { |onset| onset.split('_') }.to_set.freeze

    def self.normalize(text)
      text.to_s
          .tr("‘’", "''")
          .gsub(/\A[^\p{L}\p{N}]+|[^\p{L}\p{N}]+\z/u, '')
          .sub(/'s\z/i, '')
          .squish
          .downcase
          .first(MAX_QUERY_LENGTH)
    end

    def self.available?
      WordsmithEntry.exists?
    end

    def initialize(text)
      @query = self.class.normalize(text)
    end

    def call
      return { found: false, query: @query } if @query.blank?

      surface = WordsmithEntry.find_by(word: @query)
      base    = base_form_entry
      lemma   = surface&.senses.present? ? surface : base
      sounds  = surface || WordsmithEntry.find_by(word: @query.split.last)
      return { found: false, query: @query } unless lemma || surface

      related_entry = [surface, lemma, base].compact.find { |entry| entry.related.present? }

      {
        found:         true,
        query:         @query,
        word:          (lemma || surface).word,
        # "ran" is shown as "run"; "running" has its own entry but links to "run".
        base_form:     lemma == base ? base&.word : nil,
        see_also:      lemma == surface && base && base != surface ? base.word : nil,
        pronunciation: pronunciation_for(sounds),
        senses:        lemma&.parsed_senses || [],
        related:       related_entry&.parsed_related || [],
        related_to:    related_entry && related_entry != (lemma || surface) ? related_entry.word : nil,
        rhymes:        rhymes_for(sounds),
        near_rhymes:   near_rhymes_for(sounds)
      }
    end

    private

    def base_form_entry
      candidates = [IRREGULAR_FORMS[@query]].compact
      SUFFIX_RULES.each do |suffix, replacement|
        next unless @query.end_with?(suffix)

        stem = @query.delete_suffix(suffix) + replacement
        next if stem.length < 3

        candidates << stem
        candidates << stem[0..-2] if replacement.empty? && stem =~ /([b-df-hj-np-tv-z])\1\z/ # "running" -> "runn" -> "run"
      end

      candidates.uniq.each do |candidate|
        entry = WordsmithEntry.find_by(word: candidate)
        return entry if entry&.senses.present?
      end

      nil
    end

    def pronunciation_for(entry)
      return nil unless entry&.pronunciation

      { ipa: self.class.ipa(entry.pronunciation), syllables: entry.syllables }
    end

    # Most common first within each syllable count, so "the" leads with "a"
    # rather than "ca".
    def rhymes_for(entry)
      return [] unless entry&.rhyme_key

      WordsmithEntry.where(rhyme_key: entry.rhyme_key, common: true)
                    .where.not(word: entry.word)
                    .order(:syllables, frequency: :desc, word: :asc)
                    .limit(MAX_RHYMES)
                    .pluck(:word, :syllables)
                    .group_by(&:last)
                    .map { |syllables, words| { syllables: syllables, words: words.map(&:first) } }
    end

    # Near (slant) rhymes have the same vowels and the same kinds of consonants
    # but aren't perfect rhymes: "grief" -> "sleeve", "peace" (see
    # Wordsmith::Importer::CONSONANT_CLASSES).
    def near_rhymes_for(entry)
      return [] unless entry&.near_rhyme_key

      WordsmithEntry.where(near_rhyme_key: entry.near_rhyme_key, common: true)
                    .where.not(rhyme_key: entry.rhyme_key)
                    .order(frequency: :desc, word: :asc)
                    .limit(MAX_NEAR_RHYMES)
                    .pluck(:word)
    end

    # "K AA1 N S T AH0 N T L IY0" -> "ˈkɑnstəntli"
    def self.ipa(arpabet)
      phones = arpabet.split
      vowel  = ->(phone) { phone =~ /\d/ }
      marks  = {}

      if phones.count(&vowel) > 1
        phones.each_with_index do |phone, index|
          stress = phone[/[12]\z/] or next

          # The stress mark goes before the syllable, so pull in the consonants
          # in front of the vowel for as long as they form a legal onset.
          start = index
          start -= 1 if start.positive? && !vowel.(phones[start - 1])
          start -= 1 while start.positive? && !vowel.(phones[start - 1]) && ONSETS.include?(phones[(start - 1)...index])
          marks[start] = stress == '1' ? 'ˈ' : 'ˌ'
        end
      end

      phones.each_with_index.map do |phone, index|
        base = phone.delete('0-9')
        "#{marks[index]}#{(phone.end_with?('0') && UNSTRESSED_IPA[base]) || ARPABET_IPA[base] || base.downcase}"
      end.join
    end
  end
end
