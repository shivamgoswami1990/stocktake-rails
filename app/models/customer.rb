class Customer < ApplicationRecord
  paginates_per 10

  # Use scope function from ./app/models/concerns
  include ScopeGenerator, PgSearch::Model
  Customer.new.createScope(Customer)

  # pg_search
  pg_search_scope :search_customer, against: {
      name: 'A',
      st_address: 'B',
      city: 'C'
  }, using: {
      tsearch: { prefix: true }
  }

  # Define enum
  enum freight_type: [:HALF, :FULL]

  has_many :invoices, dependent: :destroy
  has_many :notification_objects, as: :entity
end
