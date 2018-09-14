class NotificationObject < ApplicationRecord
  belongs_to :entity, polymorphic: true
  has_many :notifications

  # Custom JSON Attributes
  def as_json(options={})
    super.as_json(options).merge({ entity: self.entity})
  end
end
