class AddTransportNameToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :transport_name, :string
  end
end
