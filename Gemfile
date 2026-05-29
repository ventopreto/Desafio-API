source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.5"

gem "rails", "~> 8.0.5"
gem "pg", "~> 1.1"
gem "solid_queue", "~> 1.1"
gem "rack-attack", "~> 6.7"
gem "pagy", "~> 9.0"
gem "alba", "~> 3.0"
gem "ransack"

gem "puma", "~> 6.4"
gem "rswag"
gem "bootsnap", ">= 1.4.4", require: false

group :development, :test do
  gem "standard"
  gem "standard-rails"
  gem "brakeman", require: false
  gem "pry-byebug"
  gem "rspec-rails", "~> 7.1"
  gem "ruby-lsp"
end

group :development do
  gem "listen", "~> 3.3"
  gem "rails-i18n", "~> 8.0"
  gem "spring"
end

group :test do
  gem "shoulda-matchers", "~> 6.0"
  gem "simplecov", require: false
end

gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
