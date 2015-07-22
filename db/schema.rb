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

ActiveRecord::Schema.define(version: 20150721033218) do

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

  create_table "bank_cards", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "number"
    t.string   "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "bankname"
  end

  create_table "daily_reports", force: :cascade do |t|
    t.date     "day"
    t.decimal  "amount"
    t.integer  "user_id"
    t.integer  "report_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "uniq_identify"
  end

  add_index "daily_reports", ["uniq_identify"], name: "index_daily_reports_on_uniq_identify", unique: true, using: :btree

  create_table "divide_incomes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "order_id"
    t.decimal  "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "enterprise_authentications", force: :cascade do |t|
    t.integer "user_id"
    t.integer "status",                               default: 0
    t.string  "enterprise_name"
    t.string  "business_license_img"
    t.string  "legal_person_identity_card_front_img"
    t.string  "legal_person_identity_card_end_img"
    t.string  "address"
    t.string  "mobile"
  end

  create_table "evaluations", force: :cascade do |t|
    t.integer  "buyer_id"
    t.integer  "sharer_id"
    t.integer  "status",          default: 0
    t.integer  "order_item_id"
    t.integer  "product_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sharing_node_id"
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
    t.string   "channel"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "prepay_id"
    t.datetime "prepay_id_expired_at"
    t.string   "pay_serial_number"
    t.decimal  "paid_amount"
    t.integer  "payment"
    t.datetime "paid_at"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "user_id"
    t.integer  "amount"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.decimal  "pay_amount",      default: 0.0
    t.integer  "sharing_node_id"
    t.integer  "evaluation_id"
    t.decimal  "present_price",   default: 0.0
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "seller_id"
    t.string   "number"
    t.string   "mobile"
    t.string   "address"
    t.string   "invoice_title"
    t.integer  "state",           default: 0
    t.decimal  "pay_amount"
    t.string   "pay_message"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "user_address_id"
    t.string   "username"
    t.decimal  "income",          default: 0.0
    t.boolean  "sharing_rewared", default: false
    t.datetime "signed_at"
    t.datetime "shiped_at"
  end

  add_index "orders", ["number"], name: "index_orders_on_number", unique: true, using: :btree

  create_table "personal_authentications", force: :cascade do |t|
    t.integer "user_id"
    t.integer "status",                      default: 0
    t.string  "name"
    t.string  "identity_card_code"
    t.string  "face_with_identity_card_img"
    t.string  "identity_card_front_img"
    t.string  "address"
    t.string  "mobile"
  end

  create_table "privilege_cards", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "user_id"
    t.decimal  "amount",     default: 0.0
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "products", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "code"
    t.decimal  "original_price",     default: 0.0
    t.decimal  "present_price",      default: 0.0
    t.integer  "count",              default: 0
    t.text     "content"
    t.boolean  "buyer_pay",          default: true
    t.decimal  "traffic_expense"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "has_share_lv",       default: 3
    t.decimal  "share_amount_total", default: 0.0
    t.decimal  "share_amount_lv_1",  default: 0.0
    t.decimal  "share_amount_lv_2",  default: 0.0
    t.decimal  "share_amount_lv_3",  default: 0.0
    t.decimal  "share_rate_lv_1",    default: 0.0
    t.decimal  "share_rate_lv_2",    default: 0.0
    t.decimal  "share_rate_lv_3",    default: 0.0
    t.decimal  "share_rate_total",   default: 0.0
    t.integer  "calculate_way",      default: 0
    t.integer  "status",             default: 0
    t.integer  "good_evaluation",    default: 0
    t.integer  "normal_evaluation",  default: 0
    t.integer  "bad_evaluation",     default: 0
    t.decimal  "privilege_amount",   default: 0.0
    t.string   "short_description"
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

  create_table "selling_incomes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.integer  "order_id"
    t.decimal  "amount"
  end

  create_table "service_notifies", force: :cascade do |t|
    t.string   "service_type"
    t.text     "content"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "sharing_incomes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "seller_id"
    t.integer  "sharing_node_id"
    t.integer  "order_item_id"
    t.decimal  "amount"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "level",           default: 1
    t.string   "number"
  end

  add_index "sharing_incomes", ["number"], name: "index_sharing_incomes_on_number", unique: true, using: :btree

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

  add_index "sharing_nodes", ["code"], name: "index_sharing_nodes_on_code", unique: true, using: :btree
  add_index "sharing_nodes", ["lft"], name: "index_sharing_nodes_on_lft", using: :btree
  add_index "sharing_nodes", ["parent_id"], name: "index_sharing_nodes_on_parent_id", using: :btree
  add_index "sharing_nodes", ["rgt"], name: "index_sharing_nodes_on_rgt", using: :btree
  add_index "sharing_nodes", ["user_id", "product_id", "parent_id"], name: "index_sharing_nodes_on_user_id_and_product_id_and_parent_id", unique: true, using: :btree
  add_index "sharing_nodes", ["user_id", "product_id"], name: "index_sharing_nodes_on_user_id_and_product_id", unique: true, where: "(parent_id IS NULL)", using: :btree

  create_table "simple_captcha_data", force: :cascade do |t|
    t.string   "key",        limit: 40
    t.string   "value",      limit: 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simple_captcha_data", ["key"], name: "idx_key", using: :btree

  create_table "transactions", force: :cascade do |t|
    t.integer  "user_id"
    t.decimal  "current_amount"
    t.decimal  "adjust_amount"
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "trade_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

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
    t.string   "area"
    t.string   "building"
  end

  create_table "user_infos", force: :cascade do |t|
    t.integer  "user_id"
    t.decimal  "income",            default: 0.0
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.decimal  "frozen_income",     default: 0.0
    t.integer  "sex"
    t.string   "city"
    t.string   "province"
    t.string   "country"
    t.integer  "good_evaluation",   default: 0
    t.integer  "normal_evaluation", default: 0
    t.integer  "bad_evaluation",    default: 0
    t.string   "store_name"
    t.integer  "service_rate",      default: 5
  end

  add_index "user_infos", ["user_id"], name: "index_user_infos_on_user_id", unique: true, using: :btree

  create_table "user_roles", force: :cascade do |t|
    t.string   "name"
    t.string   "display_name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
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
    t.integer  "user_role_id"
    t.string   "weixin_unionid"
    t.string   "weixin_openid"
    t.boolean  "need_set_login",         default: false
    t.string   "avatar"
    t.integer  "agent_id"
  end

  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "withdraw_records", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "state",           default: 0
    t.decimal  "amount",          default: 0.0
    t.string   "bank_info"
    t.datetime "process_at"
    t.datetime "done_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "bank_card_id"
    t.string   "number"
    t.string   "wx_payment_no"
    t.string   "wx_payment_time"
    t.string   "error_info"
  end

  add_index "withdraw_records", ["number"], name: "index_withdraw_records_on_number", unique: true, using: :btree

  add_foreign_key "bank_cards", "users"
  add_foreign_key "order_charges", "orders"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "order_items", "sharing_nodes"
  add_foreign_key "order_items", "users"
  add_foreign_key "orders", "user_addresses", on_delete: :nullify
  add_foreign_key "orders", "users"
  add_foreign_key "orders", "users", column: "seller_id", name: "fk_order_seller_foreign_key"
  add_foreign_key "privilege_cards", "products"
  add_foreign_key "privilege_cards", "users"
  add_foreign_key "selling_incomes", "orders"
  add_foreign_key "selling_incomes", "users"
  add_foreign_key "sharing_incomes", "order_items"
  add_foreign_key "sharing_incomes", "users"
  add_foreign_key "sharing_incomes", "users", column: "seller_id"
  add_foreign_key "sharing_nodes", "products", on_delete: :cascade
  add_foreign_key "sharing_nodes", "users", on_delete: :cascade
  add_foreign_key "transactions", "users"
  add_foreign_key "user_addresses", "users"
  add_foreign_key "user_infos", "users", on_delete: :nullify
  add_foreign_key "users", "user_roles"
  add_foreign_key "users", "users", column: "agent_id"
  add_foreign_key "withdraw_records", "bank_cards", on_delete: :nullify
  add_foreign_key "withdraw_records", "users"
end
