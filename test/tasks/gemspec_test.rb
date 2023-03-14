require "minitest"
require "open3"
require "inherited_resources/version"

class GemspecTest < Minitest::Test
  def setup
    @build = Open3.capture3("gem build inherited_resources.gemspec")
  end

  def teardown
    File.delete("inherited_resources-#{InheritedResources::VERSION}.gem")
  end

  def test_has_no_warnings
    refute_includes @build[1], "WARNING"
  end

  def test_succeeds
    assert_equal true, @build[2].success?
  end
end
