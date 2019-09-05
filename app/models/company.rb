class Company < ApplicationRecord
  # Use scope function from ./app/models/concerns
  include ScopeGenerator
  Company.new.createScope(Company)

  has_many :invoices, dependent: :destroy
  has_many :notification_objects, as: :entity
end
