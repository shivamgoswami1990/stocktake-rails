class Customer < ApplicationRecord
  after_commit :bust_customer_cache

  # Use scope function from ./app/models/concerns
  include ScopeGenerator
  Customer.new.createScope(Customer)

  # Define enum
  enum freight_type: [:HALF, :FULL]

  has_many :invoices, dependent: :destroy
  has_many :notification_objects, as: :entity

  def bust_customer_cache
    Rails.cache.redis.set("customers", Customer.all.order('name ASC').to_json)
    Rails.cache.redis.set("customers/" + self.id.to_s, self.to_json)
  end
end
