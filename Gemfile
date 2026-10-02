# frozen_string_literal: true
source 'https://rubygems.org'

gemspec path: '.'

group :development do
  gem 'rails', '~> 8.1.0'

  gem 'mocha'
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'rails-controller-testing'
  gem 'simplecov', require: false
  gem 'simplecov-cobertura'
  gem 'warning'
end

group :rubocop do
  gem 'parallel', '~> 1.28' # TODO: remove when dropping Ruby < 3.3 compatibility

  gem 'rubocop'
  gem 'rubocop-minitest'
  gem 'rubocop-packaging'
  gem 'rubocop-performance'
end
