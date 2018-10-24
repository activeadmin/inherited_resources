require File.expand_path('test_helper', File.dirname(__FILE__))

class ChangelogTest < ActiveSupport::TestCase

  def setup
    path = File.join(File.dirname(__dir__), "CHANGELOG.md")
    @changelog = File.read(path)
  end

  def test_has_definitions_for_all_implicit_links
    implicit_link_names = @changelog.scan(/\[([^\]]+)\]\[\]/).flatten.uniq
    implicit_link_names.each do |name|
      assert_includes @changelog, "[#{name}]: https"
    end
  end

  def test_entry_does_end_with_a_punctuation
    lines = @changelog.each_line
    entries = lines.grep(/^\*/)

    entries.each do |entry|
      assert_match(/(\.|\:)$/, entry)
    end
  end
end
