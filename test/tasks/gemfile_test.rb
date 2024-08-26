# frozen_string_literal: true
require "minitest"

class GemfilesTest < Minitest::Test
  def test_gemfile_is_up_to_date
    gemfile = ENV["BUNDLE_GEMFILE"] || "Gemfile"
    current_lockfile = File.read("#{gemfile}.lock")

    new_lockfile = Bundler.with_original_env do
      `bundle lock --print`
    end

    msg = "Please update #{gemfile}'s lock file with `BUNDLE_GEMFILE=#{gemfile} bundle install` and commit the result"

    assert_equal current_lockfile, new_lockfile, msg
  end
end
