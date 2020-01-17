class AddTransportGstNoToCustomers < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :transport_gst_no, :string
  end
end
