class AddPermissionsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :permissions, :json, default: {
        company: {
            create: false,
            edit: false,
            delete: false
        },
        customer: {
            create: false,
            edit: false,
            delete: false
        },
        item: {
            create: false,
            edit: false,
            delete: false
        },
        invoice: {
            create: false,
            edit: false,
            delete: false
        }
    }
    add_column :users, :is_superuser, :boolean, default: false
  end
end
