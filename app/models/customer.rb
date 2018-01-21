class Customer < ApplicationRecord

  # Use scope function from ./app/models/concerns
  include ScopeGenerator
  Customer.new.createScope(Customer)

  has_many :invoices, dependent: :destroy
end
