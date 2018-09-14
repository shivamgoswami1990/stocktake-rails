class NotificationJob < ApplicationJob
  queue_as :default

  def perform(entity_type, entity_action, entity_id, actor)
    # Define a entity description dictionary
    description_list = {
        invoice: {
            created: 'New invoice created',
            updated: 'Invoice updated',
            deleted: 'Invoice deleted'
        },
        customer: {
            created: 'New customer created',
            updated: 'Customer updated',
            deleted: 'Customer deleted'
        }
    }

    # Find the entity by entity_type
    if entity_type.eql?('invoice')
      entity = Invoice.find(entity_id)
    elsif  entity_type.eql?('customer')
      entity = Customer.find(entity_id)
    end

    # Create notification object
    notification_object = entity.notification_objects.build(description: description_list[entity_type.to_sym][entity_action.to_sym])

    if notification_object.save
      # Go through each user in user table and generate notifications with notifier ID
      User.where.not(id: actor.id).each do |user|
        Notification.create(notification_object_id: notification_object.id, notifier_id: user.id,
                            notifier_name: user.first_name + ' ' + user.last_name, actor_id: actor.id,
                            actor_name: actor.first_name + ' ' + actor.last_name)
      end

      # Do a broadcast through actioncable for this invoice
      ActionCable.server.broadcast('notification', {is_new: true, actor_id: actor.id})
    end
  end
end
