class AddLastEditedByToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_reference :customers, :last_edited_by, foreign_key: { to_table: :users }
  end
end
