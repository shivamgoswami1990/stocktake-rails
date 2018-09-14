class Company < ApplicationRecord
  after_commit :bust_company_cache

  # Use scope function from ./app/models/concerns
  include ScopeGenerator
  Company.new.createScope(Company)

  has_many :invoices, dependent: :destroy
  has_many :notification_objects, as: :entity

  def bust_company_cache
    Rails.cache.redis.set("companies", Company.all.to_json)
    Rails.cache.redis.set("companies/" + self.id.to_s, self.to_json)
  end
end
