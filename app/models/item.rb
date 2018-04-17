class Item < ApplicationRecord
  # Use scope function from ./app/models/concerns
  include ScopeGenerator
  Item.new.createScope(Item)
end
