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

<<<<<<< HEAD
ActiveRecord::Schema.define(version: 20151113032754) do
=======
ActiveRecord::Schema.define(version: 20151030093203) do
>>>>>>> 3181364... 用户退款

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agent_invite_seller_histroys", force: :cascade do |t|
    t.string   "mobile"
    t.integer  "agent_id"
    t.integer  "seller_id"
    t.integer  "status",      default: 0
    t.string   "note"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "invite_code"
    t.datetime "expire_at"
  end

  create_table "asset_imgs", force: :cascade do |t|
    t.string   "filename"
    t.string   "avatar"
    t.string   "content_type"
    t.string   "resource_type", limit: 50
    t.integer  "resource_id"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.string   "alt"
    t.string   "url"
    t.string   "image_type"
  end

  create_table "bank_cards", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "number"
    t.string   "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "bankname"
  end

  create_table "carriage_templates", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer  "cart_id"
    t.integer  "seller_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "count",                default: 0
    t.integer  "sharing_node_id"
    t.integer  "product_inventory_id"
  end

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "carts", ["user_id"], name: "index_carts_on_user_id", using: :btree

  create_table "daily_reports", force: :cascade do |t|
    t.date     "day"
    t.decimal  "amount"
    t.integer  "user_id"
    t.integer  "report_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "uniq_identify"
    t.integer  "seller_id"
  end

  add_index "daily_reports", ["uniq_identify"], name: "index_daily_reports_on_uniq_identify", unique: true, using: :btree

  create_table "descriptions", force: :cascade do |t|
    t.integer "resource_id"
    t.string  "resource_type"
    t.text    "content"
  end

  create_table "different_areas", force: :cascade do |t|
    t.integer  "carriage_template_id"
    t.integer  "first_item"
    t.decimal  "carriage"
    t.integer  "extend_item"
    t.decimal  "extend_carriage"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "different_areas_regions", id: false, force: :cascade do |t|
    t.integer "different_area_id"
    t.integer "region_id"
  end

  create_table "divide_incomes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "order_id"
    t.decimal  "amount",     default: 0.0
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "enterprise_authentications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "status",                               default: 0
    t.string   "enterprise_name"
    t.string   "business_license_img"
    t.string   "legal_person_identity_card_front_img"
    t.string   "legal_person_identity_card_end_img"
    t.string   "address"
    t.string   "mobile"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "expresses", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "private_id"
  end

  create_table "expresses_users", id: false, force: :cascade do |t|
    t.integer "express_id"
    t.integer "user_id"
  end

  create_table "favour_products", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mobile_captchas", force: :cascade do |t|
    t.string   "code"
    t.datetime "expire_at"
    t.string   "mobile"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "captcha_type"
  end

  add_index "mobile_captchas", ["mobile"], name: "index_mobile_captchas_on_mobile", using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "order_charges", force: :cascade do |t|
    t.string   "channel"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "prepay_id"
    t.datetime "prepay_id_expired_at"
    t.string   "pay_serial_number"
    t.decimal  "paid_amount",          default: 0.0
    t.integer  "payment"
    t.datetime "paid_at"
    t.string   "wx_code_url"
    t.string   "number"
    t.integer  "user_id"
    t.string   "wx_trade_type"
  end

  add_index "order_charges", ["number"], name: "index_order_charges_on_number", using: :btree

  create_table "order_item_refunds", force: :cascade do |t|
    t.decimal  "money"
    t.integer  "refund_reason_id"
    t.string   "description"
    t.integer  "order_item_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "aasm_state"
    t.integer  "order_state"
    t.string   "refund_type"
    t.integer  "user_id"
    t.jsonb    "state_at_attributes", default: {}, null: false
  end

  create_table "order_item_refunds", force: :cascade do |t|
    t.decimal  "money"
    t.integer  "refund_reason_id"
    t.string   "description"
    t.integer  "order_item_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "user_id"
    t.integer  "amount"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.decimal  "pay_amount",           default: 0.0
    t.integer  "sharing_node_id"
    t.decimal  "present_price",        default: 0.0
    t.decimal  "privilege_amount",     default: 0.0
    t.integer  "product_inventory_id"
<<<<<<< HEAD
    t.integer  "product_id"
    t.integer  "order_item_refund_id"
    t.integer  "refund_state",         default: 0
=======
    t.string   "aasm_state"
>>>>>>> 3181364... 用户退款
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "seller_id"
    t.string   "number"
    t.string   "mobile"
    t.string   "address"
    t.string   "invoice_title"
    t.integer  "state",           default: 0
    t.decimal  "pay_amount",      default: 0.0
    t.string   "pay_message"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "user_address_id"
    t.string   "username"
    t.decimal  "income",          default: 0.0
    t.boolean  "sharing_rewared", default: false
    t.datetime "signed_at"
    t.datetime "shiped_at"
    t.datetime "completed_at"
    t.string   "ship_number"
    t.integer  "express_id"
    t.string   "to_seller"
    t.decimal  "ship_price",      default: 0.0
    t.integer  "order_charge_id"
    t.decimal  "paid_amount",     default: 0.0
  end

  add_index "orders", ["number"], name: "index_orders_on_number", unique: true, using: :btree

  create_table "personal_authentications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "status",                      default: 0
    t.string   "name"
    t.string   "identity_card_code"
    t.string   "face_with_identity_card_img"
    t.string   "identity_card_front_img"
    t.string   "address"
    t.string   "mobile"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "privilege_cards", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "actived",    default: false
    t.integer  "seller_id"
  end

  create_table "product_classes", force: :cascade do |t|
    t.integer  "parent_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_inventories", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "product_class_id"
    t.integer  "count"
    t.jsonb    "sku_attributes",     default: {},   null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "user_id"
    t.string   "name"
    t.decimal  "price",              default: 0.0
    t.decimal  "share_amount_total", default: 0.0
    t.decimal  "share_amount_lv_1",  default: 0.0
    t.decimal  "share_amount_lv_2",  default: 0.0
    t.decimal  "share_amount_lv_3",  default: 0.0
    t.decimal  "privilege_amount",   default: 0.0
    t.boolean  "saling",             default: true
  end

  add_index "product_inventories", ["sku_attributes"], name: "index_product_inventories_on_sku_attributes", using: :gin

  create_table "product_properties", force: :cascade do |t|
    t.string   "name"
    t.boolean  "is_key_attr",      default: true
    t.integer  "product_class_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "product_property_values", force: :cascade do |t|
    t.string   "value"
    t.integer  "product_property_id"
    t.integer  "product_class_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "product_property_values_products", id: false, force: :cascade do |t|
    t.integer "product_id",                null: false
    t.integer "product_property_value_id", null: false
  end

  create_table "product_propertys_products", id: false, force: :cascade do |t|
    t.integer "product_id",          null: false
    t.integer "product_property_id", null: false
  end

  create_table "products", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "code"
    t.decimal  "original_price",       default: 0.0
    t.decimal  "present_price",        default: 0.0
    t.integer  "count",                default: 0
    t.decimal  "traffic_expense",      default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "has_share_lv",         default: 3
    t.decimal  "share_amount_total",   default: 0.0
    t.decimal  "share_amount_lv_1",    default: 0.0
    t.decimal  "share_amount_lv_2",    default: 0.0
    t.decimal  "share_amount_lv_3",    default: 0.0
    t.decimal  "share_rate_lv_1",      default: 0.0
    t.decimal  "share_rate_lv_2",      default: 0.0
    t.decimal  "share_rate_lv_3",      default: 0.0
    t.decimal  "share_rate_total",     default: 0.0
    t.integer  "calculate_way",        default: 0
    t.integer  "status",               default: 0
    t.integer  "good_evaluation",      default: 0
    t.integer  "bad_evaluation",       default: 0
    t.decimal  "privilege_amount",     default: 0.0
    t.string   "short_description"
    t.boolean  "hot",                  default: false
    t.integer  "carriage_template_id"
    t.integer  "transportation_way",   default: 0
    t.integer  "best_evaluation"
    t.integer  "better_evaluation"
    t.integer  "worst_evaluation"
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

  create_table "refund_messages", force: :cascade do |t|
    t.string   "message"
    t.decimal  "money"
    t.string   "user_type"
    t.integer  "user_id"
    t.string   "money_to"
    t.string   "explain"
<<<<<<< HEAD
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "refund_reason_id"
    t.string   "action"
    t.integer  "order_item_refund_id"
=======
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
>>>>>>> 3181364... 用户退款
  end

  create_table "refund_reasons", force: :cascade do |t|
    t.string   "reason"
<<<<<<< HEAD
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "reason_type"
=======
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
>>>>>>> 3181364... 用户退款
  end

  create_table "regions", force: :cascade do |t|
    t.string  "name"
    t.string  "numcode"
    t.integer "parent_id"
  end

  create_table "sales_returns", force: :cascade do |t|
    t.string   "logistics_company"
    t.string   "ship_number"
    t.string   "description"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "order_item_refund_id"
  end

  create_table "selling_incomes", force: :cascade do |t|
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "user_id"
    t.integer  "order_id"
    t.decimal  "amount",     default: 0.0
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
    t.decimal  "amount",          default: 0.0
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "level",           default: 1
    t.string   "number"
  end

  add_index "sharing_incomes", ["number"], name: "index_sharing_incomes_on_number", unique: true, using: :btree

  create_table "sharing_nodes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "product_id"
    t.string   "code"
    t.integer  "parent_id"
    t.integer  "lft",        null: false
    t.integer  "rgt",        null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "seller_id"
  end

  add_index "sharing_nodes", ["code"], name: "index_sharing_nodes_on_code", unique: true, using: :btree
  add_index "sharing_nodes", ["lft"], name: "index_sharing_nodes_on_lft", using: :btree
  add_index "sharing_nodes", ["parent_id"], name: "index_sharing_nodes_on_parent_id", using: :btree
  add_index "sharing_nodes", ["rgt"], name: "index_sharing_nodes_on_rgt", using: :btree
  add_index "sharing_nodes", ["user_id", "product_id", "parent_id"], name: "index_sharing_nodes_on_user_id_and_product_id_and_parent_id", unique: true, using: :btree
  add_index "sharing_nodes", ["user_id", "product_id"], name: "index_sharing_nodes_on_user_id_and_product_id", unique: true, where: "(parent_id IS NULL)", using: :btree
  add_index "sharing_nodes", ["user_id", "seller_id"], name: "index_sharing_nodes_on_user_id_and_seller_id", unique: true, where: "(seller_id IS NOT NULL)", using: :btree

  create_table "simple_captcha_data", force: :cascade do |t|
    t.string   "key",        limit: 40
    t.string   "value",      limit: 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simple_captcha_data", ["key"], name: "idx_key", using: :btree

  create_table "transactions", force: :cascade do |t|
    t.integer  "user_id"
    t.decimal  "current_amount", default: 0.0
    t.decimal  "adjust_amount",  default: 0.0
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "trade_type"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
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
    t.jsonb    "usage",      default: {}
    t.string   "note"
    t.integer  "post_code"
  end

  create_table "user_infos", force: :cascade do |t|
    t.integer  "user_id"
    t.decimal  "income",                    default: 0.0
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.decimal  "frozen_income",             default: 0.0
    t.integer  "sex"
    t.string   "city"
    t.string   "province"
    t.string   "country"
    t.integer  "good_evaluation",           default: 0
    t.integer  "bad_evaluation",            default: 0
    t.string   "store_name"
    t.integer  "service_rate",              default: 5
    t.json     "service_rate_histroy"
    t.string   "store_banner_one"
    t.string   "store_banner_two"
    t.string   "store_banner_thr"
    t.string   "recommend_resource_one_id"
    t.string   "recommend_resource_two_id"
    t.string   "recommend_resource_thr_id"
    t.string   "store_short_description"
    t.integer  "worst_evaluation"
    t.integer  "better_evaluation"
    t.integer  "best_evaluation"
    t.string   "store_cover"
  end

  add_index "user_infos", ["user_id"], name: "index_user_infos_on_user_id", unique: true, using: :btree

  create_table "user_role_relations", force: :cascade do |t|
    t.integer "user_id"
    t.integer "user_role_id"
  end

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
    t.string   "weixin_unionid"
    t.string   "weixin_openid"
    t.boolean  "need_set_login",         default: false
    t.string   "avatar"
    t.integer  "agent_id"
    t.integer  "authenticated",          default: 0
    t.integer  "agent_code"
    t.string   "authentication_token"
    t.decimal  "privilege_rate",         default: 50.0
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
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
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "product_inventories"
  add_foreign_key "cart_items", "users", column: "seller_id"
  add_foreign_key "carts", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "order_items", "sharing_nodes"
  add_foreign_key "order_items", "users"
  add_foreign_key "orders", "order_charges", on_delete: :nullify
  add_foreign_key "orders", "user_addresses", on_delete: :nullify
  add_foreign_key "orders", "users"
  add_foreign_key "orders", "users", column: "seller_id", name: "fk_order_seller_foreign_key"
  add_foreign_key "privilege_cards", "users"
  add_foreign_key "refund_messages", "order_item_refunds"
  add_foreign_key "selling_incomes", "orders"
  add_foreign_key "selling_incomes", "users"
  add_foreign_key "sharing_incomes", "order_items"
  add_foreign_key "sharing_incomes", "users"
  add_foreign_key "sharing_incomes", "users", column: "seller_id"
  add_foreign_key "sharing_nodes", "products", on_delete: :cascade
  add_foreign_key "sharing_nodes", "users", column: "seller_id"
  add_foreign_key "sharing_nodes", "users", on_delete: :cascade
  add_foreign_key "transactions", "users"
  add_foreign_key "user_addresses", "users"
  add_foreign_key "user_infos", "users", on_delete: :nullify
  add_foreign_key "users", "users", column: "agent_id"
  add_foreign_key "withdraw_records", "bank_cards", on_delete: :nullify
  add_foreign_key "withdraw_records", "users"
end
