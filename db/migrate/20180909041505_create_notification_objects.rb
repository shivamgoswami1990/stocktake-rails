class CreateNotificationObjects < ActiveRecord::Migration[5.2]
  def change
    create_table :notification_objects do |t|
      # Set polymorphic association with invoice, customer, company, items
      t.string :entity_type
      t.integer :entity_id
      t.string :description

      t.timestamps
    end
  end
end
