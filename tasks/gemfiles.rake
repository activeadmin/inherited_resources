desc "Bundle all Gemfiles"
task :bundle do |_t, opts|
  ["Gemfile", *Dir.glob("test/gemfiles/Gemfile-Rails-[5-9]-[0-9]")].each do |gemfile|
    Bundler.with_original_env do
      system({ "BUNDLE_GEMFILE" => gemfile }, "bundle", *opts)
    end
  end
end
