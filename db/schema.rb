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

ActiveRecord::Schema[8.1].define(version: 2026_03_16_095658) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bundles", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_bundles_on_company_id"
  end

  create_table "bundles_products", id: false, force: :cascade do |t|
    t.bigint "bundle_id", null: false
    t.bigint "product_id", null: false
    t.index ["bundle_id", "product_id"], name: "index_bundles_products_on_bundle_id_and_product_id", unique: true
    t.index ["bundle_id"], name: "index_bundles_products_on_bundle_id"
    t.index ["product_id"], name: "index_bundles_products_on_product_id"
  end

  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "forecasting_days"
    t.integer "lead_days"
    t.string "name", null: false
    t.integer "stock_days"
    t.datetime "updated_at", null: false
  end

  create_table "integration_requests", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_integration_requests_on_company_id"
  end

  create_table "integrations", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.jsonb "configuration", default: {}
    t.datetime "created_at", null: false
    t.string "provider", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "provider"], name: "index_integrations_on_company_id_and_provider", unique: true
    t.index ["company_id"], name: "index_integrations_on_company_id"
  end

  create_table "onboarding_file_uploads", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "processing_status", default: "pending", null: false
    t.string "step", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_onboarding_file_uploads_on_company_id"
  end

  create_table "onboarding_steps", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.integer "status", default: 0, null: false
    t.integer "step", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "step"], name: "index_onboarding_steps_on_company_id_and_step", unique: true
    t.index ["company_id"], name: "index_onboarding_steps_on_company_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_products_on_company_id"
  end

  create_table "products_vendors", id: false, force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "vendor_id", null: false
    t.index ["product_id", "vendor_id"], name: "index_products_vendors_on_product_id_and_vendor_id", unique: true
    t.index ["product_id"], name: "index_products_vendors_on_product_id"
    t.index ["vendor_id"], name: "index_products_vendors_on_vendor_id"
  end

  create_table "purchase_order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "expected_delivery_date"
    t.bigint "product_id", null: false
    t.bigint "purchase_order_id", null: false
    t.integer "quantity", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_purchase_order_items_on_product_id"
    t.index ["purchase_order_id"], name: "index_purchase_order_items_on_purchase_order_id"
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "order_date", null: false
    t.datetime "updated_at", null: false
    t.bigint "vendor_id", null: false
    t.index ["vendor_id"], name: "index_purchase_orders_on_vendor_id"
  end

  create_table "sales_histories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "date"], name: "index_sales_histories_on_product_id_and_date"
    t.index ["product_id"], name: "index_sales_histories_on_product_id"
  end

  create_table "vendors", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_vendors_on_company_id"
  end

  create_table "warehouses", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_warehouses_on_company_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bundles", "companies"
  add_foreign_key "bundles_products", "bundles"
  add_foreign_key "bundles_products", "products"
  add_foreign_key "integration_requests", "companies"
  add_foreign_key "integrations", "companies"
  add_foreign_key "onboarding_file_uploads", "companies"
  add_foreign_key "onboarding_steps", "companies"
  add_foreign_key "products", "companies"
  add_foreign_key "products_vendors", "products"
  add_foreign_key "products_vendors", "vendors"
  add_foreign_key "purchase_order_items", "products"
  add_foreign_key "purchase_order_items", "purchase_orders"
  add_foreign_key "purchase_orders", "vendors"
  add_foreign_key "sales_histories", "products"
  add_foreign_key "vendors", "companies"
  add_foreign_key "warehouses", "companies"
end
