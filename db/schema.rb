# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_14_030421) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.text "st_address"
    t.string "city"
    t.string "postcode"
    t.string "phone_no"
    t.string "contact_email"
    t.string "state_name"
    t.string "code"
    t.string "gstin_no"
    t.string "pan_no"
    t.string "brand_name"
    t.string "bank_name"
    t.string "bank_account_no"
    t.string "bank_branch"
    t.integer "hsn_list", default: [], array: true
    t.integer "invoice_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.text "st_address"
    t.string "city"
    t.string "postcode"
    t.string "phone_no"
    t.string "contact_email"
    t.string "state_name"
    t.string "code"
    t.string "gstin_no"
    t.string "pan_no"
    t.string "aadhar_no"
    t.integer "invoice_count", default: 0, null: false
    t.float "primary_discount", default: 0.0
    t.float "secondary_discount", default: 0.0
    t.boolean "freight_allowed", default: false
    t.integer "freight_type", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "last_edited_by_id"
    t.string "transport_name"
    t.string "destination"
    t.index ["last_edited_by_id"], name: "index_customers_on_last_edited_by_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.boolean "is_same_state_invoice", default: false
    t.integer "packaging_type", default: 1, null: false
    t.integer "invoice_status", default: 0
    t.string "invoice_no", null: false
    t.integer "invoice_no_as_int"
    t.json "company_details"
    t.json "consignee_details"
    t.json "buyer_details"
    t.datetime "invoice_date"
    t.string "delivery_note"
    t.string "terms_of_payment"
    t.string "supplier_ref"
    t.string "other_references"
    t.string "buyers_order_no"
    t.datetime "dated"
    t.string "despatch_document_no"
    t.datetime "delivery_note_date"
    t.string "despatched_through"
    t.string "destination"
    t.string "pm_no"
    t.string "no_of_packages"
    t.string "e_sugam_no"
    t.string "gross_weight"
    t.string "terms_of_delivery"
    t.string "brand_name"
    t.string "goods_description"
    t.json "item_array", default: [], array: true
    t.json "item_summary"
    t.string "amount_chargeable_in_words"
    t.json "tax_summary"
    t.string "tax_amount_in_words"
    t.string "buyer_aadhar"
    t.bigint "user_id"
    t.bigint "customer_id"
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "last_edited_by_id"
    t.string "sample_comments"
    t.string "vehicle_no"
    t.string "financial_year"
    t.integer "postage_text_options", default: 0
    t.string "despatched_through_gst"
    t.index ["company_id"], name: "index_invoices_on_company_id"
    t.index ["customer_id"], name: "index_invoices_on_customer_id"
    t.index ["invoice_no", "financial_year", "company_id"], name: "index_invoices_on_invoice_no_and_financial_year_and_company_id", unique: true
    t.index ["last_edited_by_id"], name: "index_invoices_on_last_edited_by_id"
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.float "quarter_price"
    t.float "one_tenth_price"
    t.float "half_price"
    t.float "bulk_price"
    t.float "dozen_price"
    t.float "quarter_piece_price"
    t.float "one_tenth_piece_price"
    t.float "litre_price"
    t.string "series"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_discount_enabled", default: true
  end

  create_table "notification_objects", force: :cascade do |t|
    t.string "entity_type"
    t.integer "entity_id"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.boolean "read_status", default: false
    t.string "actor_name"
    t.string "notifier_name"
    t.bigint "notification_object_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "notifier_id"
    t.bigint "actor_id"
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["notification_object_id"], name: "index_notifications_on_notification_object_id"
    t.index ["notifier_id"], name: "index_notifications_on_notifier_id"
  end

  create_table "ordered_items", force: :cascade do |t|
    t.string "item_name", null: false
    t.string "name_key", null: false
    t.float "item_price"
    t.string "units_for_display", default: "kg"
    t.float "packaging"
    t.integer "no_of_items"
    t.float "total_quantity"
    t.float "price_per_kg"
    t.string "item_hsn"
    t.float "item_amount"
    t.string "financial_year"
    t.datetime "order_date"
    t.bigint "user_id"
    t.bigint "customer_id"
    t.bigint "company_id"
    t.bigint "invoice_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_ordered_items_on_company_id"
    t.index ["customer_id"], name: "index_ordered_items_on_customer_id"
    t.index ["invoice_id"], name: "index_ordered_items_on_invoice_id"
    t.index ["user_id"], name: "index_ordered_items_on_user_id"
  end

  create_table "statistics", force: :cascade do |t|
    t.float "total_revenue", default: 0.0, null: false
    t.float "total_taxable_value", default: 0.0, null: false
    t.float "total_tax", default: 0.0, null: false
    t.float "total_insurance", default: 0.0, null: false
    t.float "total_postage", default: 0.0, null: false
    t.float "total_discount", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "financial_year"
  end

  create_table "transports", force: :cascade do |t|
    t.string "name", null: false
    t.string "location"
    t.string "gst_no"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gst_no"], name: "index_transports_on_gst_no", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "address"
    t.string "phone_no"
    t.integer "invoice_count", default: 0, null: false
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "permissions", default: {"company"=>{"create"=>false, "edit"=>false, "delete"=>false}, "customer"=>{"create"=>false, "edit"=>false, "delete"=>false}, "item"=>{"create"=>false, "edit"=>false, "delete"=>false}, "invoice"=>{"create"=>false, "edit"=>false, "delete"=>false}}
    t.boolean "is_superuser", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "customers", "users", column: "last_edited_by_id"
  add_foreign_key "invoices", "companies"
  add_foreign_key "invoices", "customers"
  add_foreign_key "invoices", "users"
  add_foreign_key "invoices", "users", column: "last_edited_by_id"
  add_foreign_key "notifications", "notification_objects"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "notifications", "users", column: "notifier_id"
  add_foreign_key "ordered_items", "companies"
  add_foreign_key "ordered_items", "customers"
  add_foreign_key "ordered_items", "invoices"
  add_foreign_key "ordered_items", "users"
end
