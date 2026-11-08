require 'test_helper'
require 'open3'
require 'minitest/mock'

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

  test "count_with_fallback returns count on success" do
    assert_equal 3, WordCountService.count_with_fallback("hello world today")
  end

  test "count_with_fallback falls back to a simple count if counting raises" do
    WordCountService.stub(:plain_text, ->(_) { raise 'boom' }) do
      assert_equal 2, WordCountService.count_with_fallback("<p>hello</p> world")
    end
  end

  test "simple_count strips HTML and splits on whitespace" do
    assert_equal 2, WordCountService.send(:simple_count, "<p>hello</p> <b>world</b>")
    assert_equal 0, WordCountService.send(:simple_count, nil)
    assert_equal 0, WordCountService.send(:simple_count, "")
  end
end
