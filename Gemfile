# frozen_string_literal: true
source 'https://rubygems.org'

gemspec path: '.'

group :development do
  gem 'rails', '~> 7.2.0'

  gem 'mocha'
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'rails-controller-testing'
  gem 'simplecov', require: false
  gem 'simplecov-cobertura'
  gem 'warning'

  # FIXME: relax this dependency when Ruby 3.1 support will be dropped
  gem "zeitwerk", "~> 2.6.18"
end

group :rubocop do
  gem 'rubocop'
  gem 'rubocop-minitest'
  gem 'rubocop-packaging'
  gem 'rubocop-performance'
end
