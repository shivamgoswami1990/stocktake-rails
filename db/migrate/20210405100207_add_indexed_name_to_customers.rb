class AddIndexedNameToCustomers < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :search_name, :string
    add_index :customers, :search_name
  end
end
