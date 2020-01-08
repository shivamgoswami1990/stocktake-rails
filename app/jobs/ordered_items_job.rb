class OrderedItemsJob < ApplicationJob
  queue_as :default

  def perform(invoice, *args)
    # Remove all the ordered items for this invoice
    OrderedItem.where(invoice_id: invoice['id']).delete_all

    item_array_list = []

    unless invoice.item_array.empty?

      # Loop through item_array
      invoice.item_array.each do |item|
        item_name_key = item['item_name'].delete(' ').downcase

        item_array_list.push({
                                 item_name: item['item_name'],
                                 name_key: item_name_key,
                                 item_price: item['item_price'],
                                 units_for_display: item['units_for_display'],
                                 packaging: item['packaging'].to_s.gsub(/[^\d^.]/, '').to_f,
                                 no_of_items: item['no_of_items'],
                                 total_quantity: item['total_quantity'].to_s.gsub(/[^\d^.]/, '').to_f,
                                 price_per_kg: item['price_per_kg'],
                                 item_hsn: item['item_hsn'],
                                 item_amount: item['item_amount'],
                                 invoice_id: invoice.id,
                                 financial_year: invoice.financial_year,
                                 customer_id: invoice.customer_id,
                                 company_id: invoice.company_id,
                                 user_id: invoice.user_id,
                                 order_date: invoice.invoice_date,
                                 created_at: invoice.invoice_date,
                                 updated_at: invoice.invoice_date,
                             })
      end
    end

    # Bulk insert all the records
    OrderedItem.insert_all(item_array_list)
  end
end
