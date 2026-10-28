require 'test_helper'

class Wordsmith::LookupTest < ActiveSupport::TestCase
  FIXTURES = Rails.root.join('test', 'fixtures', 'files', 'wordsmith')

  setup do
    Wordsmith::Importer.new(
      wordnet_dir: FIXTURES.join('dict').to_s,
      cmu_file:    FIXTURES.join('cmu.js').to_s,
      moby_file:   FIXTURES.join('moby.txt').to_s,
      logger:      Logger.new(nil)
    ).import!
  end

  def lookup(text)
    Wordsmith::Lookup.new(text).call
  end

  test "imports every word from all three sources" do
    assert WordsmithEntry.exists?(word: 'grief')    # WordNet + CMU + Moby
    assert WordsmithEntry.exists?(word: 'explain')  # CMU only
    assert WordsmithEntry.exists?(word: 'cunning')  # CMU + Moby
    assert_nil WordsmithEntry.find_by(word: 'grief(2)')
  end

  test "only ordinary words are offered as rhymes" do
    assert WordsmithEntry.find_by(word: 'beef').common
    refute WordsmithEntry.find_by(word: 'japan').common, 'proper nouns are not common'
    refute WordsmithEntry.find_by(word: 'amd').common, 'acronyms read letter by letter are not common'
  end

  test "looks up definitions, synonyms and pronunciation" do
    result = lookup('grief')

    assert result[:found]
    assert_equal 'grief', result[:word]
    assert_equal 'intense sorrow caused by loss of a loved one (especially by death)', result[:senses].first['definition']
    assert_equal %w(heartache heartbreak), result[:senses].first['synonyms']
    assert_equal({ ipa: 'ɡɹif', syllables: 1 }, result[:pronunciation])
  end

  test "parses examples and verb frames" do
    sense = lookup('run')[:senses].first

    assert_equal 'verb', sense['pos']
    assert_equal "move fast by using one's feet", sense['definition']
    assert_equal ["Don't run--you'll be out of breath"], sense['examples']
    assert_equal ['scarper'], sense['synonyms']
  end

  test "satellite adjectives borrow antonyms from their head" do
    sense = lookup('vehement')[:senses].first

    assert_equal ['intense'], sense['similar']
    assert_equal ['mild'], sense['antonyms']
  end

  test "related words put lowercase headwords before proper nouns" do
    related = lookup('grief')[:related]

    assert_includes related, 'affliction'
    assert_equal 'Sorrow Street', related.last
  end

  test "groups perfect rhymes by syllable count" do
    assert_equal [{ syllables: 1, words: %w(beef brief) }, { syllables: 2, words: %w(belief) }], lookup('grief')[:rhymes]
  end

  test "ranks near rhymes with similar-sounding endings first" do
    assert_equal %w(sleeve beam), lookup('grief')[:near_rhymes]
  end

  test "irregular and inflected forms show their base form" do
    ran = lookup('ran')
    assert_equal 'run', ran[:word]
    assert_equal 'run', ran[:base_form]
    assert_equal 'ɹæn', ran[:pronunciation][:ipa], 'pronunciation is for the word as written'

    running = lookup('Running,')
    assert_equal 'run', running[:word]
    assert_equal ['cunning'], running[:rhymes].flat_map { |group| group[:words] }
  end

  test "words without thesaurus entries use their base form's related words" do
    result = lookup('vehemently')

    assert_equal 'vehemently', result[:word]
    assert_equal 'vehement', result[:see_also]
    assert_equal 'vehement', result[:related_to]
    assert_includes result[:related], 'fervent'
  end

  test "normalizes selections" do
    assert_equal 'grief', Wordsmith::Lookup.normalize("  “Grief’s”  ")
    assert_equal 'well as', Wordsmith::Lookup.normalize("well   as,")
  end

  test "reports unknown words" do
    assert_equal({ found: false, query: 'xyzzy' }, lookup('xyzzy'))
    assert_equal({ found: false, query: '' }, lookup('  ...  '))
  end

  test "converts pronunciations to IPA with stress marks" do
    assert_equal 'ɪkˈspleɪn', Wordsmith::Lookup.ipa('IH0 K S P L EY1 N')
    assert_equal 'ˈviəməntli', Wordsmith::Lookup.ipa('V IY1 AH0 M AH0 N T L IY0')
    assert_equal 'ɡɹif', Wordsmith::Lookup.ipa('G R IY1 F')
  end
end
