class AddFinancialYearToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :financial_year, :string
    add_index :invoices, [:invoice_no, :financial_year, :company_id], unique: true
  end
end
