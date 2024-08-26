# frozen_string_literal: true
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

  def test_succeeds
    assert_predicate @build[2], :success?
  end
end
