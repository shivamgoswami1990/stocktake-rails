class Customer < ApplicationRecord
  # Use scope function from ./app/models/concerns
  include ScopeGenerator, PgSearch::Model
  Customer.new.createScope(Customer)

  after_commit :update_customers_cache

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
  has_many :ordered_items, dependent: :destroy
  has_many :notification_objects, as: :entity


  private

  def update_customers_cache
    update_cache("customers", self)
  end
end
