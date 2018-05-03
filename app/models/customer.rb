class Customer < ApplicationRecord
  after_commit :bust_customer_cache

  # Use scope function from ./app/models/concerns
  include ScopeGenerator
  Customer.new.createScope(Customer)

  # Define enum
  enum freight_type: [:HALF, :FULL]

  has_many :invoices, dependent: :destroy

  def bust_customer_cache
    Rails.cache.redis.set("customers", Customer.all.to_json)
    Rails.cache.redis.set("customers/" + self.id.to_s, self.to_json)
  end
end
