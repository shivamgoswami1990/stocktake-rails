class Invoice < ApplicationRecord
  # Use scope function from ./app/models/concerns
  include ScopeGenerator, PgSearch
  pg_search_scope :search_by_item_array, :against => :item_array
  Invoice.new.createScope(Invoice)

  belongs_to :user
  belongs_to :customer
  belongs_to :company

  counter_culture :company, column_name: proc {|model| model.invoice_status.eql?('SAVED') ? 'invoice_count' : nil},
                  column_names: {
                      ["invoices.invoice_status = ?", 1] => 'invoice_count'
                  }
  counter_culture :customer, column_name: proc {|model| model.invoice_status.eql?('SAVED') ? 'invoice_count' : nil},
                  column_names: {
                      ["invoices.invoice_status = ?", 1] => 'invoice_count'
                  }
  counter_culture :user, column_name: proc {|model| model.invoice_status.eql?('SAVED') ? 'invoice_count' : nil},
                  column_names: {
                      ["invoices.invoice_status = ?", 1] => 'invoice_count'
                  }

  # Define enum
  enum invoice_status: [:DRAFT, :SAVED]

  # Custom JSON Attributes
  def as_json(options={})
    super.as_json(options).merge({ user: self.user, company: self.company, customer: self.customer})
  end

  after_commit :update_statistics, :bust_invoice_cache # Move this to sidekiq once activejobs are included
  after_create_commit :notify_users

  private
  def notify_users
    ActionCable.server.broadcast('invoices', {'invoice_no' => self.invoice_no,
                                              'notification_type' => 'new_invoice',
                                              'is_same_state_invoice' => self.is_same_state_invoice,
                                              'company_details' => self.company_details,
                                              'consignee_details' => self.consignee_details,
                                              'user' => self.user,
                                              'last_edited_by_id' => self.last_edited_by_id,
                                              'last_edited_by_details' => User.find(self.last_edited_by_id)
    })
  end

  def bust_invoice_cache
    Rails.cache.redis.set("invoices/" + self.id.to_s, self.to_json)
  end


  def update_statistics
    total_revenue = 0
    total_taxable_value = 0
    total_tax = 0
    total_insurance = 0
    total_postage = 0
    total_discount = 0

    Invoice.all.pluck(:item_summary, :tax_summary).each do |invoice|
      invoice_item_summary = invoice[0]
      invoice_tax_summary = invoice[1]

      total_revenue += invoice_item_summary['total_after_round_off'].to_f if invoice_item_summary['total_after_round_off'].present?
      total_taxable_value += invoice_tax_summary['hsn_summary_total']['total_taxable_value'].to_f if invoice_tax_summary.present?
      total_tax += invoice_tax_summary['hsn_summary'][0]['total_tax_amount'].to_f if invoice_tax_summary.present?
      total_insurance += invoice_item_summary['insurance_percentage_amount'].to_f if invoice_item_summary['insurance_percentage_amount'].present?
      total_postage += invoice_item_summary['postage_charge'].to_f if invoice_item_summary['postage_charge'].present?
      total_discount += invoice_item_summary['discount'].to_f if invoice_item_summary['discount'].present?
    end

    # Save these stats to the Statistics model
    statistic = Statistic.first

    if statistic
      statistic.update(total_revenue: total_revenue.to_f, total_taxable_value: total_taxable_value.to_f, total_tax: total_tax.to_f,
                     total_insurance: total_insurance.to_f, total_postage: total_postage.to_f, total_discount: total_discount.to_f)
      statistic.save
    end
  end
end
