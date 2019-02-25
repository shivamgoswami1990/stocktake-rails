class AddVehicleNoToInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :vehicle_no, :string
  end
end
