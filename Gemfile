# frozen_string_literal: true
source 'https://rubygems.org'

gemspec path: '.'

group :development do
  gem 'rails', '~> 8.1.0'

  gem 'mocha', '~> 2.8' # TODO: relax this dependency after fixing #981
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'rails-controller-testing'
  gem 'simplecov', require: false
  gem 'simplecov-cobertura'
  gem 'warning'
end

group :rubocop do
  gem 'rubocop'
  gem 'rubocop-minitest'
  gem 'rubocop-packaging'
  gem 'rubocop-performance'
end
