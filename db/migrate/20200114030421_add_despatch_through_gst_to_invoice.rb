class AddDespatchThroughGstToInvoice < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :despatched_through_gst, :string
  end
end
