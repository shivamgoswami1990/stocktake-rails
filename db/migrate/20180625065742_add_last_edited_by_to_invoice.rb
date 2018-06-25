class AddLastEditedByToInvoice < ActiveRecord::Migration[5.2]
  def change
    add_reference :invoices, :last_edited_by, foreign_key: { to_table: :users }
  end
end
