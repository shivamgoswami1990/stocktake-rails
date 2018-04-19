class CreateStatistics < ActiveRecord::Migration[5.2]
  def change
    create_table :statistics do |t|

      t.float :total_revenue, null: false, default: 0
      t.float :total_taxable_value, null: false, default: 0
      t.float :total_tax, null: false, default: 0
      t.float :total_insurance, null: false, default: 0
      t.float :total_postage, null: false, default: 0
      t.float :total_discount, null: false, default: 0

      t.timestamps
    end
  end
end
