class RemoveFieldsFromInvoice < ActiveRecord::Migration[5.2]
  def change
    remove_column :invoices, :company_pan, :string
    remove_column :invoices, :company_bank_name, :string
    remove_column :invoices, :company_account_no, :string
    remove_column :invoices, :branch_ifs_code, :string
  end
end
