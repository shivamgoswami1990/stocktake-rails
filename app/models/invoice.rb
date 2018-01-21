class Invoice < ApplicationRecord

  # Use scope function from ./app/models/concerns
  include ScopeGenerator
  Invoice.new.createScope(Invoice)

  belongs_to :user
  belongs_to :customer
  belongs_to :company

  # Define enum
  enum invoice_status: [:DRAFT, :SAVED]

  # Custom JSON Attributes
  def as_json(options={})
    super.as_json(options).merge({ user: self.user, company: self.company, customer: self.customer})
  end
end
