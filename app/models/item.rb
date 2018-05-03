class Item < ApplicationRecord
  after_commit :bust_item_cache

  # Use scope function from ./app/models/concerns
  include ScopeGenerator
  Item.new.createScope(Item)

  def bust_item_cache
    Rails.cache.redis.set("items", Item.all.to_json)
    Rails.cache.redis.set("items/" + self.id.to_s, self.to_json)
  end
end
