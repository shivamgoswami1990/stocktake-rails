class CreateCustomers < ActiveRecord::Migration[5.1]
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
      t.string :vat_tin_no

      t.timestamps
    end
  end
end
