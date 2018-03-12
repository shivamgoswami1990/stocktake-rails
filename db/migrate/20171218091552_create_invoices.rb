class CreateInvoices < ActiveRecord::Migration[5.1]
  def change
    create_table :invoices do |t|

      t.boolean :is_same_state_invoice, default: false
      t.integer :invoice_status, default: 0
      t.string :invoice_no, null: false

      # Company details
      t.json :company_details

      # Consignee details
      t.json :consignee_details

      # Buyer details
      t.json :buyer_details

      t.datetime :invoice_date
      t.string :delivery_note
      t.string :terms_of_payment
      t.string :supplier_ref
      t.string :other_references

      t.string :buyers_order_no
      t.datetime :dated
      t.string :despatch_document_no
      t.datetime :delivery_note_date
      t.string :despatched_through
      t.string :destination

      t.string :pm_no
      t.string :no_of_packages
      t.string :e_sugam_no
      t.string :gross_weight
      t.string :terms_of_delivery

      t.string :brand_name

      t.json :item_array, array: true, default: []
      t.json :item_summary
      t.string :amount_chargeable_in_words
      t.json :tax_summary
      t.string :tax_amount_in_words

      t.string :company_vat_tin
      t.string :buyer_vat_tin
      t.string :company_pan

      t.string :company_bank_name
      t.string :company_account_no
      t.string :branch_ifs_code

      t.references :user, index: true, foreign_key: true
      t.references :customer, index: true, foreign_key: true
      t.references :company, index: true, foreign_key: true

      t.timestamps
    end

    add_index :invoices, :invoice_no, unique: true
  end
end
