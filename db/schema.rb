# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_26_120000) do
  create_table "cryptic_types", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.integer "points", default: 100, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_cryptic_types_on_key", unique: true
    t.check_constraint "points BETWEEN 10 AND 1000", name: "cryptic_types_points_range"
  end

  create_table "cryptics", force: :cascade do |t|
    t.string "source_id", null: false
    t.text "statement", null: false
    t.string "enumeration", null: false
    t.string "answer", null: false
    t.json "definitions", default: [], null: false
    t.json "indicators", default: [], null: false
    t.json "material", default: [], null: false
    t.integer "cryptic_type_id", null: false
    t.integer "difficulty_id", null: false
    t.text "help_text"
    t.text "explanation"
    t.string "author"
    t.string "origin", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_cryptics_on_active"
    t.index ["cryptic_type_id"], name: "index_cryptics_on_cryptic_type_id"
    t.index ["difficulty_id"], name: "index_cryptics_on_difficulty_id"
    t.index ["source_id"], name: "index_cryptics_on_source_id", unique: true
    t.check_constraint "json_type(definitions) = 'array'", name: "cryptics_definitions_is_array"
    t.check_constraint "json_type(indicators) = 'array'", name: "cryptics_indicators_is_array"
    t.check_constraint "json_type(material) = 'array'", name: "cryptics_material_is_array"
    t.check_constraint "length(trim(statement)) > 0 AND length(trim(answer)) > 0", name: "cryptics_statement_and_answer_not_blank"
  end

  create_table "difficulties", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.decimal "multiplier", precision: 3, scale: 2, null: false
    t.integer "reference_seconds", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_difficulties_on_key", unique: true
    t.index ["position"], name: "index_difficulties_on_position", unique: true
    t.check_constraint "multiplier > 0 AND multiplier <= 5", name: "difficulties_multiplier_range"
    t.check_constraint "reference_seconds > 0", name: "difficulties_reference_seconds_positive"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "cryptics_source_url", null: false
    t.text "welcome_text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "id = 1", name: "settings_single_row"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "score_editor", null: false
    t.boolean "active", default: true, null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.check_constraint "role IN ('admin', 'score_editor')", name: "users_role_check"
  end

  add_foreign_key "cryptics", "cryptic_types"
  add_foreign_key "cryptics", "difficulties"
  add_foreign_key "sessions", "users"
end
