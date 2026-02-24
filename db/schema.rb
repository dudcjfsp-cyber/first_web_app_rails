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

ActiveRecord::Schema[8.1].define(version: 2026_02_24_093000) do
  create_table "record_sheet_indices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "record_id", null: false
    t.integer "row_number", null: false
    t.string "sheet_name", null: false
    t.datetime "updated_at", null: false
    t.index ["record_id"], name: "index_record_sheet_indices_on_record_id", unique: true
    t.index ["sheet_name", "row_number"], name: "index_record_sheet_indices_on_sheet_name_and_row_number"
  end

  create_table "records", force: :cascade do |t|
    t.string "company_name", null: false
    t.datetime "created_at", null: false
    t.string "product_name", null: false
    t.integer "quantity", null: false
    t.string "record_id", null: false
    t.string "request_id", null: false
    t.datetime "submitted_at_utc", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["record_id"], name: "index_records_on_record_id", unique: true
    t.index ["request_id"], name: "index_records_on_request_id"
    t.index ["user_id"], name: "index_records_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "auth_uid", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.index ["auth_uid"], name: "index_users_on_auth_uid", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "records", "users"
end
