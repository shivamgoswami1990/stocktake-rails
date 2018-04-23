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

      t.timestamps
    end
  end
end
