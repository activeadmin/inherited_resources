require "minitest"

class GemfilesTest < Minitest::Test
  ["Gemfile", *Dir.glob("test/rails_[5-9][0-9]/Gemfile")].each do |gemfile|
    define_method :"test_#{gemfile}_is_up_to_date" do
      current_lockfile = File.read("#{gemfile}.lock")

      new_lockfile = Bundler.with_original_env do
        `BUNDLE_GEMFILE=#{gemfile} bundle lock --print`
      end

      msg = "Please update #{gemfile}'s lock file with `BUNDLE_GEMFILE=#{gemfile} bundle install` and commit the result"

      assert_equal current_lockfile, new_lockfile, msg
    end
  end
end
