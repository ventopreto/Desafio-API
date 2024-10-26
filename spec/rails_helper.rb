require "spec_helper"
require "shoulda/matchers"
require "simplecov"

SimpleCov.start "rails" do
  add_filter "channels"
  add_filter "mailers"
  add_filter "jobs"
end

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.fixture_path = "#{Rails.root.join("spec/fixtures")}"

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
end

def json_response
  JSON.parse(response.body)
end
