# frozen_string_literal: true
require "minitest/autorun"
require "bundler"
require "fileutils"
require "open3"
require "tmpdir"

class GemspecTest < Minitest::Test
  def setup
    @output_dir = Dir.mktmpdir
    @gem_path = File.join(@output_dir, "inherited_resources.gem")
  end

  def teardown
    FileUtils.remove_entry(@output_dir)
  end

  def test_succeeds
    stdout, stderr, status = Bundler.with_original_env do
      Open3.capture3("gem", "build", "inherited_resources.gemspec", "--output", @gem_path)
    end

    assert_predicate status, :success?, "gem build failed (#{status})\n#{stdout}\n#{stderr}"
    assert_path_exists @gem_path
  end
end
