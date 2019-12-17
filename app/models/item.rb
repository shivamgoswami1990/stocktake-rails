class Item < ApplicationRecord
  # Use scope function from ./app/models/concerns
  include ScopeGenerator, PgSearch::Model
  Item.new.createScope(Item)

  after_commit :update_items_cache

  # pg_search
  pg_search_scope :search_item, against: {
      name: 'A',
      series: 'B'
  }, using: {
      tsearch: { prefix: true }
  }

  private

  def update_items_cache
    update_cache("items", self)
  end
end
