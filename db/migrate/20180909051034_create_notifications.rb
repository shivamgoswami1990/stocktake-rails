class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|

      t.boolean :read_status, default: false
      t.string :actor_name
      t.string :notifier_name
      t.references :notification_object, index: true, foreign_key: true
      t.timestamps
    end

    add_reference :notifications, :notifier, references: :users, index: true
    add_foreign_key :notifications, :users, column: :notifier_id

    add_reference :notifications, :actor, references: :users, index: true
    add_foreign_key :notifications, :users, column: :actor_id
  end
end
