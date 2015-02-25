# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150221130128) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "assets", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "serial"
    t.uuid     "company_id"
    t.string   "identification"
    t.string   "certificate"
    t.datetime "calibration_date"
    t.datetime "due_date"
    t.uuid     "laboratory_id"
    t.string   "visa_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "model_id"
  end

  add_index "assets", ["laboratory_id"], name: "index_assets_on_laboratory_id", using: :btree

  create_table "companies", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "name"
    t.text     "address"
    t.text     "details"
    t.uuid     "laboratory_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "companies", ["laboratory_id"], name: "index_companies_on_laboratory_id", using: :btree

  create_table "kinds", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "name"
    t.uuid     "laboratory_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "kinds", ["laboratory_id"], name: "index_kinds_on_laboratory_id", using: :btree

  create_table "laboratories", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "name"
    t.string   "subdomain"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "custom_forms"
  end

  create_table "manufacturers", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "name"
    t.uuid     "laboratory_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "manufacturers", ["laboratory_id"], name: "index_manufacturers_on_laboratory_id", using: :btree

  create_table "models", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "name"
    t.uuid     "manufacturer_id"
    t.uuid     "kind_id"
    t.uuid     "laboratory_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "models", ["laboratory_id"], name: "index_models_on_laboratory_id", using: :btree

  create_table "report_templates", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "name"
    t.text     "value"
    t.uuid     "laboratory_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "report_templates", ["laboratory_id"], name: "index_report_templates_on_laboratory_id", using: :btree

  create_table "reports", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "name"
    t.text     "value"
    t.uuid     "service_id"
    t.uuid     "laboratory_id"
    t.uuid     "report_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reports", ["laboratory_id"], name: "index_reports_on_laboratory_id", using: :btree

  create_table "roles", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "laboratory_id"
    t.string   "name",          null: false
    t.string   "title",         null: false
    t.text     "description",   null: false
    t.json     "the_role",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["laboratory_id"], name: "index_roles_on_laboratory_id", using: :btree

  create_table "services", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "order_number"
    t.text     "details"
    t.uuid     "laboratory_id"
    t.uuid     "user_id"
    t.boolean  "validated"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "asset_id"
    t.json     "information"
    t.datetime "calibration_date"
  end

  add_index "services", ["laboratory_id"], name: "index_services_on_laboratory_id", using: :btree

  create_table "snippets", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.integer  "flavor"
    t.json     "value"
    t.boolean  "validated"
    t.uuid     "laboratory_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "snippets", ["laboratory_id"], name: "index_snippets_on_laboratory_id", using: :btree

  create_table "spreadsheets", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "description"
    t.json     "table_json"
    t.uuid     "service_id"
    t.uuid     "laboratory_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "spreadsheets", ["laboratory_id"], name: "index_spreadsheets_on_laboratory_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.uuid     "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.string   "taggable_type", limit: 256
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.uuid     "laboratory_id"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.uuid     "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "company_id"
    t.string   "name"
    t.string   "title"
  end

  add_index "users", ["email", "laboratory_id"], name: "index_users_on_email_and_laboratory_id", unique: true, using: :btree
  add_index "users", ["laboratory_id"], name: "index_users_on_laboratory_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "workbenches", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid    "service_id",           null: false
    t.uuid    "asset_id",             null: false
    t.integer "position",   limit: 8
  end

  add_index "workbenches", ["service_id", "asset_id"], name: "index_workbenches_on_service_id_and_asset_id", using: :btree

end
