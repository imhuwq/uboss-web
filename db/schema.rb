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

ActiveRecord::Schema.define(version: 20150605052125) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "asset_imgs", force: :cascade do |t|
    t.string   "filename"
    t.string   "avatar"
    t.string   "content_type"
    t.string   "resource_type", limit: 50
    t.integer  "resource_id"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.string   "alt"
  end

  create_table "product_share_issues", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "buyer_lv_1_id"
    t.integer  "buyer_lv_2_id"
    t.integer  "buyer_lv_3_id"
    t.integer  "sharer_lv_1_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "code"
    t.float    "original_price",     default: 0.0
    t.float    "present_price",      default: 0.0
    t.integer  "count",              default: 0
    t.text     "content"
    t.boolean  "buyer_pay",          default: true
    t.float    "traffic_expense"
    t.float    "buyer_lv_1",         default: 0.0
    t.float    "buyer_lv_2",         default: 0.0
    t.float    "buyer_lv_3",         default: 0.0
    t.float    "sharer_lv_1",        default: 0.0
    t.integer  "buyer_present_way",  default: 0
    t.integer  "sharer_present_way", default: 0
    t.string   "img_avatar"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "simple_captcha_data", force: :cascade do |t|
    t.string   "key",        limit: 40
    t.string   "value",      limit: 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simple_captcha_data", ["key"], name: "idx_key", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "login",                  default: "",    null: false
    t.string   "email"
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "mobile"
    t.boolean  "admin",                  default: false
  end

  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
