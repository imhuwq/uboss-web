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

ActiveRecord::Schema.define(version: 20160421041504) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activity_draw_records", force: :cascade do |t|
    t.integer "user_id"
    t.integer "sharer_id"
    t.integer "promotion_activity_id"
    t.integer "activity_info_id"
    t.integer "draw_count"
  end

  create_table "activity_infos", force: :cascade do |t|
    t.integer  "promotion_activity_id"
    t.string   "activity_type"
    t.string   "name"
    t.decimal  "price",                 default: 0.0
    t.integer  "expiry_days",           default: 0
    t.integer  "win_count",             default: 0
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "draw_count",            default: 0
    t.float    "win_rate",              default: 1.0
    t.integer  "surplus",               default: 0
  end

  add_index "activity_infos", ["promotion_activity_id"], name: "index_activity_infos_on_promotion_activity_id", using: :btree

  create_table "activity_prizes", force: :cascade do |t|
    t.integer  "prize_winner_id"
    t.integer  "promotion_activity_id"
    t.integer  "activity_info_id"
    t.jsonb    "info"
    t.string   "activity_type"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "sharer_id"
    t.integer  "relate_winner_id"
  end

  create_table "advertisements", force: :cascade do |t|
    t.string   "advertisement_url"
    t.integer  "status",                 default: 0
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "order_number"
    t.integer  "user_id"
    t.integer  "zone"
    t.integer  "product_id"
    t.integer  "category_id"
    t.boolean  "platform_advertisement", default: false
    t.string   "user_type"
  end

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

  add_index "agent_invite_seller_histroys", ["invite_code", "agent_id"], name: "index_agent_invite_seller_histroys_on_invite_code_and_agent_id", unique: true, using: :btree
  add_index "agent_invite_seller_histroys", ["mobile", "agent_id"], name: "index_agent_invite_seller_histroys_on_mobile_and_agent_id", unique: true, using: :btree

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
    t.string   "remark"
  end

  create_table "bill_incomes", force: :cascade do |t|
    t.decimal  "amount"
    t.integer  "user_id"
    t.integer  "bill_order_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "bill_incomes", ["user_id", "bill_order_id"], name: "index_bill_incomes_on_user_id_and_bill_order_id", unique: true, using: :btree

  create_table "bill_orders", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "seller_id"
    t.string   "number"
    t.integer  "state"
    t.decimal  "pay_amount"
    t.decimal  "paid_amount"
    t.integer  "order_charge_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "weixin_openid"
    t.string   "user_identify"
  end

  add_index "bill_orders", ["number"], name: "index_bill_orders_on_number", unique: true, using: :btree

  create_table "bonus_records", force: :cascade do |t|
    t.decimal  "amount"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "user_id"
    t.string   "type"
    t.integer  "inviter_id"
    t.boolean  "actived"
    t.integer  "bonus_resource_id"
    t.string   "bonus_resource_type"
    t.jsonb    "properties",          default: {}
  end

  create_table "calling_notifies", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "table_number_id"
    t.integer  "calling_service_id"
    t.datetime "called_at"
    t.integer  "status",             default: 0
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "calling_notifies", ["calling_service_id"], name: "index_calling_notifies_on_calling_service_id", using: :btree
  add_index "calling_notifies", ["table_number_id"], name: "index_calling_notifies_on_table_number_id", using: :btree
  add_index "calling_notifies", ["user_id"], name: "index_calling_notifies_on_user_id", using: :btree

  create_table "calling_services", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "calling_services", ["user_id"], name: "index_calling_services_on_user_id", using: :btree

  create_table "captcha_sending_histories", force: :cascade do |t|
    t.string   "code"
    t.datetime "code_sent_at"
    t.datetime "code_expired_at"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.string   "receiver_mobile"
    t.integer  "invite_type"
    t.integer  "invite_status"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "captcha_sending_histories", ["receiver_id"], name: "index_captcha_sending_histories_on_receiver_id", using: :btree
  add_index "captcha_sending_histories", ["sender_id"], name: "index_captcha_sending_histories_on_sender_id", using: :btree

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

  add_index "cart_items", ["product_inventory_id", "cart_id"], name: "index_cart_items_on_product_inventory_id_and_cart_id", unique: true, using: :btree

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "carts", ["user_id"], name: "index_carts_on_user_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name",                           null: false
    t.integer  "user_id",                        null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.datetime "use_in_store_at"
    t.boolean  "use_in_store",    default: true
    t.integer  "store_id"
    t.string   "store_type"
    t.integer  "position"
  end

  add_index "categories", ["user_id", "name", "store_id"], name: "index_categories_on_user_id_and_name_and_store_id", unique: true, using: :btree

  create_table "categories_products", id: false, force: :cascade do |t|
    t.integer "product_id",  null: false
    t.integer "category_id", null: false
  end

  add_index "categories_products", ["category_id"], name: "index_categories_products_on_category_id", using: :btree
  add_index "categories_products", ["product_id"], name: "index_categories_products_on_product_id", using: :btree

  create_table "certifications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "status"
    t.string   "name"
    t.string   "enterprise_name"
    t.string   "id_num"
    t.string   "address"
    t.string   "mobile"
    t.string   "attachment_1"
    t.string   "attachment_2"
    t.string   "attachment_3"
    t.string   "type"
    t.datetime "verified_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "province_code"
    t.string   "city_code"
    t.string   "district_code"
  end

  add_index "certifications", ["user_id"], name: "index_certifications_on_user_id", using: :btree

  create_table "city_managers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "category"
    t.string   "city"
    t.decimal  "rate",       precision: 2, scale: 2
    t.datetime "settled_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "cooperations", force: :cascade do |t|
    t.integer  "supplier_id"
    t.integer  "agency_id"
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.decimal  "yday_performance",  precision: 8,  scale: 2, default: 0.0
    t.decimal  "total_performance", precision: 10, scale: 2, default: 0.0
  end

  add_index "cooperations", ["agency_id"], name: "index_cooperations_on_agency_id", using: :btree
  add_index "cooperations", ["supplier_id", "agency_id"], name: "index_cooperations_on_supplier_id_and_agency_id", unique: true, using: :btree
  add_index "cooperations", ["supplier_id"], name: "index_cooperations_on_supplier_id", using: :btree

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
    t.string  "content_type"
  end

  add_index "descriptions", ["resource_type", "resource_id", "content_type"], name: "index_description_uniq_resouce_relate", using: :btree

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
    t.decimal  "amount",        default: 0.0
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "bill_order_id"
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

  add_index "enterprise_authentications", ["user_id"], name: "index_enterprise_authentications_on_user_id", unique: true, using: :btree

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
    t.integer  "order_id"
  end

  create_table "expresses", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "private_id"
  end

  add_index "expresses", ["name"], name: "index_expresses_on_name", unique: true, using: :btree

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

  add_index "favour_products", ["product_id", "user_id"], name: "index_favour_products_on_product_id_and_user_id", unique: true, using: :btree

  create_table "job_histories", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "status"
    t.string   "message"
    t.string   "resource_type"
    t.string   "resource_id"
    t.string   "job_class"
    t.string   "job_method"
    t.jsonb    "options"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "json_test", force: :cascade do |t|
    t.jsonb "data"
  end

  create_table "mobile_captchas", force: :cascade do |t|
    t.string   "code"
    t.datetime "expire_at"
    t.string   "mobile"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "captcha_type"
    t.integer  "sender_id"
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
    t.string   "address"
    t.string   "return_explain"
    t.datetime "deal_at"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "user_id"
    t.integer  "amount"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.decimal  "pay_amount",           default: 0.0
    t.integer  "sharing_node_id"
    t.decimal  "present_price",        default: 0.0
    t.decimal  "privilege_amount",     default: 0.0
    t.integer  "product_inventory_id"
    t.integer  "order_item_refund_id"
    t.string   "sku_properties"
    t.boolean  "recommend",            default: false
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
    t.string   "type"
    t.integer  "supplier_id"
  end

  add_index "orders", ["number"], name: "index_orders_on_number", unique: true, using: :btree
  add_index "orders", ["type"], name: "index_orders_on_type", using: :btree

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

  add_index "personal_authentications", ["identity_card_code"], name: "index_personal_authentications_on_identity_card_code", unique: true, using: :btree
  add_index "personal_authentications", ["user_id"], name: "index_personal_authentications_on_user_id", unique: true, using: :btree

  create_table "preferential_measures", force: :cascade do |t|
    t.decimal  "amount"
    t.decimal  "discount"
    t.decimal  "total_amount"
    t.string   "type"
    t.integer  "preferential_item_id"
    t.string   "preferential_item_type"
    t.integer  "preferential_source_id"
    t.string   "preferential_source_type"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "privilege_cards", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.boolean  "actived",              default: false
    t.integer  "seller_id"
    t.integer  "product_inventory_id"
    t.string   "user_img"
    t.string   "service_store_cover"
    t.string   "user_name"
    t.string   "ordinary_store_cover"
    t.datetime "qrcode_expire_at",     default: '2016-03-03 14:49:49'
    t.string   "service_store_name"
    t.string   "ordinary_store_name"
    t.boolean  "activity",             default: false
  end

  add_index "privilege_cards", ["user_id", "seller_id"], name: "index_privilege_cards_on_user_id_and_seller_id", unique: true, using: :btree

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
    t.jsonb    "sku_attributes",      default: {},   null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "user_id"
    t.string   "name"
    t.decimal  "price",               default: 0.0
    t.decimal  "share_amount_total",  default: 0.0
    t.decimal  "share_amount_lv_1",   default: 0.0
    t.decimal  "share_amount_lv_2",   default: 0.0
    t.decimal  "share_amount_lv_3",   default: 0.0
    t.decimal  "privilege_amount",    default: 0.0
    t.boolean  "saling",              default: true
    t.string   "type"
    t.decimal  "cost_price"
    t.decimal  "suggest_price_lower"
    t.decimal  "suggest_price_upper"
    t.boolean  "sale_to_agency"
    t.integer  "parent_id"
    t.boolean  "sale_to_customer",    default: true
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
    t.boolean  "full_cut",             default: false
    t.integer  "full_cut_number"
    t.integer  "full_cut_unit"
    t.integer  "total_sales"
    t.integer  "comprehensive_order"
    t.datetime "published_at"
    t.string   "type"
    t.integer  "service_type"
    t.integer  "monthes"
    t.integer  "service_store_id"
    t.integer  "sales_amount",         default: 0
    t.integer  "sales_amount_order"
    t.integer  "parent_id"
    t.integer  "supplier_id"
    t.decimal  "rebate_amount"
    t.string   "price_ranges"
  end

  add_index "products", ["type"], name: "index_products_on_type", using: :btree

  create_table "promotion_activities", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "status",     default: 0
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "store_type", default: "service"
  end

  add_index "promotion_activities", ["user_id"], name: "index_promotion_activities_on_user_id", using: :btree

  create_table "purchase_orders", force: :cascade do |t|
    t.integer  "seller_id"
    t.integer  "supplier_id"
    t.integer  "state"
    t.string   "number"
    t.integer  "order_id"
    t.decimal  "pay_amount",  precision: 10, scale: 2
    t.datetime "paid_at"
    t.decimal  "income",      precision: 10, scale: 2
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "purchase_orders", ["seller_id"], name: "index_purchase_orders_on_seller_id", using: :btree
  add_index "purchase_orders", ["supplier_id"], name: "index_purchase_orders_on_supplier_id", using: :btree

  create_table "recommends", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "recommended_id"
    t.string   "recommended_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
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
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "refund_reason_id"
    t.string   "action"
    t.integer  "order_item_refund_id"
  end

  create_table "refund_reasons", force: :cascade do |t|
    t.string   "reason"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "reason_type"
  end

  create_table "refund_records", force: :cascade do |t|
    t.integer  "order_item_refund_id"
    t.string   "out_trade_no"
    t.decimal  "total_fee",            default: 0.0
    t.decimal  "refund_fee",           default: 0.0
    t.string   "out_refund_no"
    t.datetime "applied_at"
    t.string   "applied_status"
    t.datetime "refunded_at"
    t.string   "refund_channel"
    t.string   "refund_status"
    t.integer  "query_count",          default: 0
    t.text     "applied_content"
    t.text     "query_content"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "refund_records", ["order_item_refund_id"], name: "index_refund_records_on_order_item_refund_id", using: :btree

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
    t.integer  "lft",          null: false
    t.integer  "rgt",          null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "seller_id"
    t.integer  "self_page_id"
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

  create_table "stock_movements", force: :cascade do |t|
    t.integer  "product_inventory_id"
    t.integer  "originator_id"
    t.string   "originator_type"
    t.integer  "quantity"
    t.integer  "action"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "store_phones", force: :cascade do |t|
    t.string   "area_code"
    t.string   "fixed_line"
    t.string   "phone_number"
    t.integer  "service_store_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "sub_accounts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "account_id"
    t.integer  "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sub_accounts", ["user_id", "account_id"], name: "index_sub_accounts_on_user_id_and_account_id", unique: true, using: :btree

  create_table "supplier_product_infos", force: :cascade do |t|
    t.decimal  "cost_price"
    t.decimal  "suggest_price_lower"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.decimal  "suggest_price_upper"
    t.integer  "supply_status",       default: 0
    t.integer  "supplier_product_id"
  end

  add_index "supplier_product_infos", ["supplier_product_id"], name: "index_supplier_product_infos_on_supplier_product_id", unique: true, using: :btree

  create_table "supplier_store_infos", force: :cascade do |t|
    t.string   "guess_province"
    t.string   "guess_city"
    t.string   "phone_number"
    t.string   "wechat_id"
    t.integer  "supplier_store_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "supplier_store_infos", ["supplier_store_id"], name: "index_supplier_store_infos_on_supplier_store_id", unique: true, using: :btree

  create_table "table_numbers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "number"
    t.integer  "status",     default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "expired_at"
  end

  add_index "table_numbers", ["user_id"], name: "index_table_numbers_on_user_id", using: :btree

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
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "default",        default: false
    t.string   "area"
    t.string   "building"
    t.jsonb    "usage",          default: {}
    t.string   "note"
    t.integer  "post_code"
    t.boolean  "seller_address", default: false
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
    t.decimal  "bonus_benefit",             default: 0.0
    t.string   "type"
    t.string   "begin_hour"
    t.string   "begin_minute"
    t.string   "end_hour"
    t.string   "end_minute"
    t.string   "area"
    t.string   "street"
    t.integer  "platform_service_rate",     default: 0
    t.integer  "agent_service_rate",        default: 0
    t.integer  "table_count",               default: 0
    t.integer  "table_expired_in",          default: 0
  end

  create_table "user_role_relations", force: :cascade do |t|
    t.integer "user_id"
    t.integer "user_role_id"
  end

  add_index "user_role_relations", ["user_id", "user_role_id"], name: "index_user_role_relations_on_user_id_and_user_role_id", unique: true, using: :btree

  create_table "user_roles", force: :cascade do |t|
    t.string   "name"
    t.string   "display_name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "user_roles", ["name"], name: "index_user_roles_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "login"
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
    t.string   "rongcloud_token"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["agent_code"], name: "index_users_on_agent_code", unique: true, using: :btree
  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "verify_codes", force: :cascade do |t|
    t.string   "code"
    t.boolean  "verified",          default: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "sharing_rewared",   default: false
    t.decimal  "income",            default: 0.0
    t.boolean  "expired",           default: false
    t.integer  "activity_prize_id"
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "user_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "wechat_accounts", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "weixin_secret_key"
    t.string   "weixin_token"
    t.string   "encoding_aes_key",    limit: 43
    t.string   "app_id"
    t.string   "encoding_app_secret"
    t.string   "wechat_identify"
  end

  add_index "wechat_accounts", ["weixin_secret_key"], name: "index_wechat_accounts_on_weixin_secret_key", using: :btree
  add_index "wechat_accounts", ["weixin_token"], name: "index_wechat_accounts_on_weixin_token", using: :btree

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

  create_table "wx_scenes", force: :cascade do |t|
    t.datetime "expire_at"
    t.string   "scene_str"
    t.string   "scene_id"
    t.jsonb    "properties", default: {}
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "user_id"
  end

  add_foreign_key "activity_infos", "promotion_activities"
  add_foreign_key "bank_cards", "users"
  add_foreign_key "bill_orders", "order_charges"
  add_foreign_key "bill_orders", "users"
  add_foreign_key "bill_orders", "users", column: "seller_id"
  add_foreign_key "bonus_records", "users"
  add_foreign_key "calling_notifies", "calling_services"
  add_foreign_key "calling_notifies", "table_numbers"
  add_foreign_key "calling_notifies", "users"
  add_foreign_key "calling_services", "users"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "product_inventories"
  add_foreign_key "cart_items", "users", column: "seller_id"
  add_foreign_key "carts", "users"
  add_foreign_key "categories", "users"
  add_foreign_key "categories_products", "categories"
  add_foreign_key "categories_products", "products"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "order_items", "sharing_nodes"
  add_foreign_key "order_items", "users"
  add_foreign_key "orders", "order_charges", on_delete: :nullify
  add_foreign_key "orders", "user_addresses", on_delete: :nullify
  add_foreign_key "orders", "users"
  add_foreign_key "orders", "users", column: "seller_id", name: "fk_order_seller_foreign_key"
  add_foreign_key "privilege_cards", "users"
  add_foreign_key "promotion_activities", "users"
  add_foreign_key "refund_messages", "order_item_refunds"
  add_foreign_key "refund_records", "order_item_refunds"
  add_foreign_key "selling_incomes", "orders"
  add_foreign_key "selling_incomes", "users"
  add_foreign_key "sharing_incomes", "order_items"
  add_foreign_key "sharing_incomes", "users"
  add_foreign_key "sharing_incomes", "users", column: "seller_id"
  add_foreign_key "sharing_nodes", "products", on_delete: :cascade
  add_foreign_key "sharing_nodes", "users", column: "seller_id"
  add_foreign_key "sharing_nodes", "users", on_delete: :cascade
  add_foreign_key "sub_accounts", "users"
  add_foreign_key "sub_accounts", "users", column: "account_id"
  add_foreign_key "table_numbers", "users"
  add_foreign_key "transactions", "users"
  add_foreign_key "user_addresses", "users"
  add_foreign_key "user_infos", "users", on_delete: :nullify
  add_foreign_key "users", "users", column: "agent_id"
  add_foreign_key "withdraw_records", "bank_cards", on_delete: :nullify
  add_foreign_key "withdraw_records", "users"
end
