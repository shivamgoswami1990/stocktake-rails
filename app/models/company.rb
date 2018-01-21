class Company < ApplicationRecord

  # Use scope function from ./app/models/concerns
  include ScopeGenerator
  Company.new.createScope(Company)

  has_many :invoices, dependent: :destroy
end
