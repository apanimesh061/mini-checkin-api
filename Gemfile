source 'https://rubygems.org'
ruby "2.3.1"

gem 'rack-cors'
gem 'mysql2'
gem 'activerecord', '~> 4.2.0', :require => 'active_record'
gem 'hashie-forbidden_attributes'
gem 'honeybadger', '~> 1.16.7'
gem 'json'
gem 'napa', '~> 0.5.0'
gem 'roar', '~> 0.12.0'
gem 'grape-swagger'

group :development,:test do
  gem 'pry'
end

group :development do
  gem 'rubocop', require: false
  gem 'shotgun', require: false
end

group :test do
  gem 'factory_girl'
  gem 'rspec'
  gem 'rack-test'
  gem 'simplecov'
  gem 'webmock'
  gem 'database_cleaner'
  gem 'shoulda-matchers', '~> 2.8.0'
end
