class AddDestinationToCustomer < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :destination, :string
  end
end
