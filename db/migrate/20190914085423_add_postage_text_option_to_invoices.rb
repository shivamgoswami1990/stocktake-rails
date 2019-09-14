class AddPostageTextOptionToInvoices < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :postage_text_options, :integer, default: 0
  end
end
