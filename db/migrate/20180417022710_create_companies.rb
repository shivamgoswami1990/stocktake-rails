class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.string :name
      t.text :st_address
      t.string :city
      t.string :postcode
      t.string :phone_no
      t.string :contact_email
      t.string :state_name
      t.string :code
      t.string :gstin_no
      t.string :pan_no
      t.string :brand_name
      t.string :bank_name
      t.string :bank_account_no
      t.string :bank_branch
      t.integer :hsn_list, array: true, default: []

      t.integer :invoice_count, null: false, default: 0

      t.timestamps
    end
  end
end
