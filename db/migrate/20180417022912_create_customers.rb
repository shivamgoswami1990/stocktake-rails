class CreateCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :customers do |t|
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
      t.string :aadhar_no

      t.integer :invoice_count, null: false, default: 0

      t.float :primary_discount, default: 0.00
      t.float :secondary_discount, default: 0.00

      t.boolean :freight_allowed, default: false
      t.integer :freight_type, null: false, default: 0

      t.text :notes
      t.timestamps
    end
  end
end
