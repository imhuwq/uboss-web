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

ActiveRecord::Schema.define(version: 20150604071848) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "product_share_issues", force: :cascade do |t|
    t.integer "product_id"
    t.float   "buyer_lv_1",         default: 0.0
    t.float   "buyer_lv_2",         default: 0.0
    t.float   "buyer_lv_3",         default: 0.0
    t.float   "sharer_lv_1",        default: 0.0
    t.integer "buyer_present_way",  default: 0
    t.integer "sharer_present_way", default: 0
  end

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "user_id"
    t.integer  "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "seller_id"
    t.string   "number"
    t.string   "mobile"
    t.string   "address"
    t.string   "invoice_title"
    t.integer  "state",         default: 0
    t.integer  "payment"
    t.datetime "pay_time"
    t.float    "pay_amount"
    t.string   "pay_message"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "orders", ["number"], name: "index_orders_on_number", unique: true, using: :btree

  create_table "products", force: :cascade do |t|
    t.string  "name"
    t.float   "original_price"
    t.float   "present_price"
    t.integer "count"
    t.text    "content"
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

  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "order_items", "users"
  add_foreign_key "orders", "users"
  add_foreign_key "orders", "users", column: "seller_id", name: "fk_order_seller_foreign_key"
end
