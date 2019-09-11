class AddFinancialYearToStatistic < ActiveRecord::Migration[6.0]
  def change
    add_column :statistics, :financial_year, :string
  end
end
