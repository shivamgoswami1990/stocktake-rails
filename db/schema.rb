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

ActiveRecord::Schema.define(version: 2018_05_02_002749) do

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
    t.index ["company_id"], name: "index_invoices_on_company_id"
    t.index ["customer_id"], name: "index_invoices_on_customer_id"
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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "invoices", "companies"
  add_foreign_key "invoices", "customers"
  add_foreign_key "invoices", "users"
end
