class Notification < ApplicationRecord
  paginates_per 10

  # Use scope function from ./app/models/concerns
  include ScopeGenerator
  Notification.new.createScope(Notification)

  belongs_to :user, optional: true
  belongs_to :notification_object

  # Custom JSON Attributes
  def as_json(options={})
    super.as_json(options).merge({ notification_object: self.notification_object})
  end
end
