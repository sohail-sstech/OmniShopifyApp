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

ActiveRecord::Schema.define(version: 2019_07_02_095446) do

  create_table "countries", force: :cascade do |t|
    t.string "iso", limit: 2
    t.string "name", limit: 80
    t.string "nicename", limit: 80
    t.string "iso3", limit: 3
    t.integer "numcode", limit: 6
    t.integer "phonecode", limit: 5
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_exclusion_tags", force: :cascade do |t|
    t.integer "shop_id"
    t.string "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_product_exclusion_tags_on_shop_id"
  end

  create_table "reasons", force: :cascade do |t|
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "shop_id"
  end

  create_table "rule_options", force: :cascade do |t|
    t.integer "shop_id"
    t.integer "rule_id"
    t.integer "refund_method", limit: 3, default: 1
    t.integer "return_window", limit: 3, default: 0
    t.integer "return_shipping_fee", limit: 2, default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rule_id"], name: "index_rule_options_on_rule_id"
    t.index ["shop_id"], name: "index_rule_options_on_shop_id"
  end

  create_table "rules", force: :cascade do |t|
    t.integer "shop_id"
    t.string "name", limit: 80
    t.integer "priority", limit: 5, default: 1
    t.text "conditions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_rules_on_shop_id"
  end

  create_table "shop_reasons", force: :cascade do |t|
    t.integer "shop_id"
    t.string "reason_ids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_shop_reasons_on_shop_id"
  end

  create_table "shop_settings", force: :cascade do |t|
    t.integer "shop_id"
    t.string "token", limit: 255
    t.integer "create_order_webhook_id", limit: 20
    t.integer "uninstall_app_webhook_id", limit: 20
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_shop_settings_on_shop_id"
  end

  create_table "shops", force: :cascade do |t|
    t.string "shopify_domain", null: false
    t.string "shopify_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shopify_domain"], name: "index_shops_on_shopify_domain", unique: true
  end

end
