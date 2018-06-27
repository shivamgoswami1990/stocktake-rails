class AddSampleCommentsToInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :sample_comments, :string
  end
end
