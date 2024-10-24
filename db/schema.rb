ActiveRecord::Schema.define(version: 2024_10_24_184247) do
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "movies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.string "genre"
    t.integer "year"
    t.string "country"
    t.date "published_at"
    t.text "description"
    t.datetime "created_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
  end
end
