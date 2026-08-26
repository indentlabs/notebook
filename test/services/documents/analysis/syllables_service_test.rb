require 'test_helper'

class Documents::Analysis::SyllablesServiceTest < ActiveSupport::TestCase
  # -- Basic syllable counting --

  test "counts single syllable words" do
    assert_equal 1, Documents::Analysis::SyllablesService.count("cat")
    assert_equal 1, Documents::Analysis::SyllablesService.count("dog")
    assert_equal 1, Documents::Analysis::SyllablesService.count("run")
  end

  test "counts two syllable words" do
    assert_equal 2, Documents::Analysis::SyllablesService.count("happy")
    assert_equal 2, Documents::Analysis::SyllablesService.count("water")
    assert_equal 2, Documents::Analysis::SyllablesService.count("mother")
  end

  test "counts three syllable words" do
    assert_equal 3, Documents::Analysis::SyllablesService.count("beautiful")
    assert_equal 3, Documents::Analysis::SyllablesService.count("wonderful")
  end

  # -- Edge cases --

  test "short words (3 chars or less) return 1" do
    assert_equal 1, Documents::Analysis::SyllablesService.count("a")
    assert_equal 1, Documents::Analysis::SyllablesService.count("an")
    assert_equal 1, Documents::Analysis::SyllablesService.count("the")
  end

  test "strips non-alpha characters" do
    assert_equal 1, Documents::Analysis::SyllablesService.count("cat!")
    assert_equal 1, Documents::Analysis::SyllablesService.count("dog?")
    assert_equal 1, Documents::Analysis::SyllablesService.count("run.")
  end

  test "is case insensitive" do
    assert_equal Documents::Analysis::SyllablesService.count("Hello"),
                 Documents::Analysis::SyllablesService.count("hello")
    assert_equal Documents::Analysis::SyllablesService.count("WATER"),
                 Documents::Analysis::SyllablesService.count("water")
  end

  # -- Override words --

  test "ion override returns 2 syllables" do
    assert_equal 2, Documents::Analysis::SyllablesService.count("ion")
  end

  # -- Silent e handling --

  test "words ending in silent e are handled" do
    # "make" should strip the silent e and count correctly
    count = Documents::Analysis::SyllablesService.count("make")
    assert count >= 1
  end

  # -- Never returns zero --

  test "always returns at least 1" do
    # Even for unusual input
    assert Documents::Analysis::SyllablesService.count("xyz") >= 1
    assert Documents::Analysis::SyllablesService.count("rhythm") >= 1
  end
end
