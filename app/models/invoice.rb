class Invoice < ApplicationRecord
  # Use scope function from ./app/models/concerns
  include ScopeGenerator
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
end
