# frozen_string_literal: true
require "minitest/autorun"

class GemfilesTest < Minitest::Test
  def test_gemfile_is_up_to_date
    gemfile = ENV["BUNDLE_GEMFILE"] || "Gemfile"
    current_lockfile = File.read("#{gemfile}.lock")

    new_lockfile = Bundler.with_original_env do
      `bundle lock --print`
    end

    msg = "Please update #{gemfile}'s lock file with `BUNDLE_GEMFILE=#{gemfile} bundle install` and commit the result"

    # The BUNDLED WITH section only records the Bundler version that wrote the
    # lockfile, so ignore it to avoid failing when only that version differs.
    assert_equal strip_bundled_with(current_lockfile), strip_bundled_with(new_lockfile), msg
  end

  def test_strip_bundled_with_ignores_only_the_bundler_version
    lockfile = "GEM\r\n  specs:\r\n    rake (13.0.0)\r\n\r\nBUNDLED WITH\r\n   2.5.0\r\n"

    assert_equal "GEM\n  specs:\n    rake (13.0.0)", strip_bundled_with(lockfile)
    assert_equal strip_bundled_with(lockfile), strip_bundled_with(lockfile.sub("2.5.0", "4.0.1"))
    assert_equal "GEM\n  specs:", strip_bundled_with("GEM\n  specs:\n")
  end

  private

    def strip_bundled_with(lockfile)
      lockfile.gsub("\r\n", "\n").sub(/\n?BUNDLED WITH\n.*\z/m, "").strip
    end
end
