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

ActiveRecord::Schema.define(version: 20150623041214) do

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
    t.string   "url"
  end

  create_table "mobile_auth_codes", force: :cascade do |t|
    t.string   "code"
    t.datetime "expire_at"
    t.string   "mobile"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_charges", force: :cascade do |t|
    t.integer  "order_id"
    t.string   "charge_id"
    t.string   "channel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "user_id"
    t.integer  "amount"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.float    "pay_amount",      default: 0.0
    t.integer  "sharing_node_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "seller_id"
    t.string   "number"
    t.string   "mobile"
    t.string   "address"
    t.string   "invoice_title"
    t.integer  "state",           default: 0
    t.integer  "payment"
    t.datetime "pay_time"
    t.float    "pay_amount"
    t.string   "pay_message"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "user_address_id"
    t.string   "username"
    t.float    "income",          default: 0.0
    t.boolean  "sharing_rewared", default: false
  end

  add_index "orders", ["number"], name: "index_orders_on_number", unique: true, using: :btree

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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "has_share_lv",       default: 3
    t.float    "share_amount_total", default: 0.0
    t.float    "share_amount_lv_1",  default: 0.0
    t.float    "share_amount_lv_2",  default: 0.0
    t.float    "share_amount_lv_3",  default: 0.0
    t.float    "share_rate_lv_1",    default: 0.0
    t.float    "share_rate_lv_2",    default: 0.0
    t.float    "share_rate_lv_3",    default: 0.0
    t.float    "share_rate_total",   default: 0.0
    t.integer  "calculate_way",      default: 0
    t.integer  "status",             default: 0
  end

  create_table "redactor_assets", force: :cascade do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "redactor_assets", ["assetable_type", "assetable_id"], name: "idx_redactor_assetable", using: :btree
  add_index "redactor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_redactor_assetable_type", using: :btree

  create_table "sharing_incomes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "seller_id"
    t.integer  "sharing_node_id"
    t.integer  "order_item_id"
    t.float    "amount"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "level",           default: 1
  end

  create_table "sharing_nodes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "product_id"
    t.integer  "order_id"
    t.string   "code"
    t.integer  "parent_id"
    t.integer  "lft",        null: false
    t.integer  "rgt",        null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sharing_nodes", ["lft"], name: "index_sharing_nodes_on_lft", using: :btree
  add_index "sharing_nodes", ["parent_id"], name: "index_sharing_nodes_on_parent_id", using: :btree
  add_index "sharing_nodes", ["rgt"], name: "index_sharing_nodes_on_rgt", using: :btree

  create_table "simple_captcha_data", force: :cascade do |t|
    t.string   "key",        limit: 40
    t.string   "value",      limit: 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simple_captcha_data", ["key"], name: "idx_key", using: :btree

  create_table "user_addresses", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "username"
    t.string   "province"
    t.string   "city"
    t.string   "country"
    t.string   "street"
    t.string   "mobile"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "default",    default: false
  end

  create_table "user_infos", force: :cascade do |t|
    t.integer  "user_id"
    t.float    "income"
    t.float    "income_level_one"
    t.float    "income_level_two"
    t.float    "income_level_thr"
    t.float    "sharing_counter"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

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
    t.boolean  "need_reset_password",    default: false
    t.string   "nickname"
  end

  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "order_charges", "orders"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "order_items", "sharing_nodes"
  add_foreign_key "order_items", "users"
  add_foreign_key "orders", "user_addresses", on_delete: :nullify
  add_foreign_key "orders", "users"
  add_foreign_key "orders", "users", column: "seller_id", name: "fk_order_seller_foreign_key"
  add_foreign_key "sharing_incomes", "order_items"
  add_foreign_key "sharing_incomes", "users"
  add_foreign_key "sharing_incomes", "users", column: "seller_id"
  add_foreign_key "sharing_nodes", "products", on_delete: :cascade
  add_foreign_key "sharing_nodes", "users", on_delete: :cascade
  add_foreign_key "user_addresses", "users"
  add_foreign_key "user_infos", "users", on_delete: :nullify
end
