ActiveRecord::Schema.define(version: 2024_10_25_015945) do
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "movie_imports", force: :cascade do |t|
    t.string "file_name"
    t.string "error_message"
    t.integer "status"
    t.integer "movies_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

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
