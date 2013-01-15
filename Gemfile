source 'https://rubygems.org'

gem 'rails', '3.2.9'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
end

gem 'mysql2'
gem 'jquery-rails'
gem 'twitter-bootstrap-rails', "= 2.1.3"
gem 'devise', "~> 2.1.2"
gem 'redcarpet', '1.17.2'
gem "state_machine", "~> 1.1.2"
gem 'bootstrap-datepicker-rails'

group :development do
  gem 'capistrano', "~> 2.13.5"
  gem 'rvm-capistrano'
  gem 'capistrano-ext', "~> 1.2.1"
  gem 'thin', '~> 1.5.0'
  gem 'annotate', ">=2.5.0"
end

group :development, :test do
  gem 'debugger'
  gem 'rspec-rails', "~> 2.11.4"
  gem 'ZenTest', '~> 4.8.1'
  gem 'autotest-growl', '~> 0.2.16'
  gem 'autotest-rails-pure', '~> 4.1.2'
  gem 'sqlite3', '~> 1.3.4'
end

group :test do
  gem 'factory_girl_rails', '~> 4.1.0'
  gem 'simplecov', '~> 0.6.4', :require => false
  gem 'timecop', '~> 0.5.2'
  gem 'ci_reporter'
  gem 'webmock', '~> 1.8.11'
end
