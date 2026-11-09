require 'test_helper'
require 'open3'

class WordCountServiceTest < ActiveSupport::TestCase
  CASES_PATH = Rails.root.join('test/fixtures/files/word_count_cases.json')
  JS_COUNTER_PATH = Rails.root.join('app/assets/javascripts/word_count.js')

  def cases
    @cases ||= JSON.parse(File.read(CASES_PATH))
  end

  test "counts every shared case as expected" do
    failures = cases.reject { |c| WordCountService.count(c['text']) == c['words'] }.map do |c|
      "#{c['text'].inspect}: expected #{c['words']}, got #{WordCountService.count(c['text'])}"
    end

    assert_empty failures, "WordCountService miscounted:\n  #{failures.join("\n  ")}"
  end

  # The editors show live counts with app/assets/javascripts/word_count.js. If it drifted from the
  # server, a writer would see one number while typing and another on every other page.
  test "the JavaScript counter agrees with the server on every shared case" do
    node = ENV.fetch('NODE', 'node')
    skip 'node is not installed' unless system(node, '--version', out: File::NULL, err: File::NULL)

    script = <<~JS
      const counter = require(#{JS_COUNTER_PATH.to_s.to_json});
      const cases = require(#{CASES_PATH.to_s.to_json});
      process.stdout.write(JSON.stringify(cases.map((c) => counter.count(c.text))));
    JS
    output, status = Open3.capture2(node, '-e', script)
    assert status.success?, "node failed: #{output}"

    failures = cases.zip(JSON.parse(output)).reject { |c, js| js == c['words'] }.map do |c, js|
      "#{c['text'].inspect}: expected #{c['words']}, JavaScript counted #{js}"
    end

    assert_empty failures, "word_count.js disagrees with the shared cases:\n  #{failures.join("\n  ")}"
  end

  # Each of these took from seconds to an hour with regexes that backtrack. Every step of the counter
  # must stay linear, since it runs on whatever a writer saves, in requests and on the one worker.
  ADVERSARIAL_INPUTS = {
    'unclosed styles'     => '<style>' * 50_000,
    'unclosed scripts'    => '<script> ' * 50_000,
    'unclosed comments'   => '<!--' * 50_000,
    'punctuation in a token with a slash' => 'a/' + '!' * 200_000 + 'b',
    'tag starts'          => '<a' * 100_000,
    'angle brackets'      => '<' * 200_000,
    'ampersands'          => '&amp' * 50_000,
    'dots'                => '.' * 200_000,
    'link prefixes'       => 'www.' * 50_000 + '/x',
    'schemes'             => 'http://' * 30_000 + '/x',
    'non-ASCII text with tags' => "\u00E9<b>" * 50_000
  }.freeze

  test "counting takes linear time even on malformed input" do
    ADVERSARIAL_INPUTS.each do |name, text|
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      WordCountService.count(text)
      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started

      assert_operator elapsed, :<, 2.0, "counting #{name} (#{text.bytesize} bytes) took #{elapsed.round(2)}s"
    end
  end

  test "the JavaScript counter takes linear time on malformed input too" do
    node = ENV.fetch('NODE', 'node')
    skip 'node is not installed' unless system(node, '--version', out: File::NULL, err: File::NULL)

    script = <<~JS
      const counter = require(#{JS_COUNTER_PATH.to_s.to_json});
      const inputs = JSON.parse(require('fs').readFileSync(0, 'utf8'));
      const timings = {};
      for (const [name, text] of Object.entries(inputs)) {
        const started = process.hrtime.bigint();
        counter.count(text);
        timings[name] = Number(process.hrtime.bigint() - started) / 1e9;
      }
      process.stdout.write(JSON.stringify(timings));
    JS
    output, status = Open3.capture2(node, '-e', script, stdin_data: ADVERSARIAL_INPUTS.to_json)
    assert status.success?, "node failed: #{output}"

    JSON.parse(output).each do |name, elapsed|
      assert_operator elapsed, :<, 2.0, "word_count.js counting #{name} took #{elapsed.round(2)}s"
    end
  end

  test "returns 0 for nil" do
    assert_equal 0, WordCountService.count(nil)
  end

  test "counts a whole novel the same way it counts a chapter" do
    chapter = (["<p>She opened the door\u2014slowly. \u201CHello?\u201D Nobody answered.</p>"] * 50).join
    chapter_words = WordCountService.count(chapter)
    assert_equal 400, chapter_words

    novel = chapter * 300 # ~1MB of HTML, about 120,000 words
    assert_operator novel.bytesize, :>, 900_000
    assert_equal chapter_words * 300, WordCountService.count(novel)
  end

  test "handles text that isn't valid UTF-8" do
    assert_equal 2, WordCountService.count("caf\xE9 time".dup.force_encoding('ASCII-8BIT'))
    assert_equal 2, WordCountService.count("bad \xFF bytes".dup.force_encoding('UTF-8'))
  end

  test "plain_text shows what a reader sees" do
    assert_equal " Hello \u00A0world ", WordCountService.plain_text('<p>Hello &nbsp;<b>world</b></p>')
  end

  # Safari before 16.4 can't parse a regex lookbehind, and one it can't parse stops every script in
  # the bundle, the document editor's autosave included.
  test "no browser JavaScript uses a regex lookbehind" do
    offenders = Dir[Rails.root.join('app/{assets/javascripts,javascript}/**/*.js')].select do |path|
      File.read(path).match?(/\(\?<[!=]/)
    end

    assert_empty offenders, "These use a regex lookbehind:\n  #{offenders.join("\n  ")}"
  end
end
