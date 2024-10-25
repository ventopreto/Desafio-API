source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.4"

gem "rails", "~> 6.1.7", ">= 6.1.7.9"
gem "pg", "~> 1.1"

gem "puma", "~> 5.0"

gem "bootsnap", ">= 1.4.4", require: false

group :development, :test do
  gem "standard"
  gem "standard-rails"
  gem "pry-byebug"
  gem "rspec-rails", "~> 4.1.2"
  gem "ruby-lsp"
end

group :development do
  gem "listen", "~> 3.3"
  gem "rails-i18n", "~> 6.0"
  gem "spring"
end

group :test do
  gem "shoulda-matchers", "~> 6.0"
  gem "simplecov", require: false
end

gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
