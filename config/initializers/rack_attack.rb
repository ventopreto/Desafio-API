class Rack::Attack
  IMPORT_LIMIT = 5
  READ_LIMIT = 60
  THROTTLE_WINDOW = 1.minute

  throttle("imports/ip", limit: IMPORT_LIMIT, period: THROTTLE_WINDOW) do |req|
    req.ip if req.post? && req.path == "/api/v1/movies"
  end

  throttle("api-read/ip", limit: READ_LIMIT, period: THROTTLE_WINDOW) do |req|
    req.ip if req.get? && req.path.start_with?("/api/v1/")
  end

  self.throttled_responder = lambda do |req|
    [
      429,
      {"Content-Type" => "application/json; charset=utf-8"},
      [{error: I18n.t("messages.rate_limit.too_many_requests")}.to_json]
    ]
  end
end

Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new if Rails.env.test?
