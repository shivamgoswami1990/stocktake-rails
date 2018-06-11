class Customer < ApplicationRecord
  after_commit :bust_customer_cache
  after_create_commit :notify_users

  # Use scope function from ./app/models/concerns
  include ScopeGenerator
  Customer.new.createScope(Customer)

  # Define enum
  enum freight_type: [:HALF, :FULL]

  has_many :invoices, dependent: :destroy

  def bust_customer_cache
    Rails.cache.redis.set("customers", Customer.all.order('name ASC').to_json)
    Rails.cache.redis.set("customers/" + self.id.to_s, self.to_json)
  end

  def notify_users
    ActionCable.server.broadcast('invoices', {'notification_type' => 'new_customer',
                                              'name' => self.name
    })
  end
end
