class Customer < ApplicationRecord
  # Use scope function from ./app/models/concerns
  include ScopeGenerator
  Customer.new.createScope(Customer)

  # Define enum
  enum freight_type: [:HALF, :FULL]

  has_many :invoices, dependent: :destroy
end
