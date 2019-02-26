class NotificationsController < ApplicationController
  include HasScopeGenerator #located at /app/controllers/concerns/has_scope_generator.rb
  before_action :authenticate_user!
  require "json"

  #//////////////////////////////////////////// SCOPES ////////////////////////////////////////////////////////////////

  #Initialise scopes using concerns
  NotificationsController.new.scope_initialize(NotificationsController, Notification)

  #//////////////////////////////////////////// REST API //////////////////////////////////////////////////////////////

  # GET /unread_notification_count?user_id=1
  def unread_notification_count
    render :json => Notification.where('notifier_id = ? AND read_status = false', params[:user_id]).count
  end

  # GET /unread_notifications?user_id=1
  def unread_notifications
    render :json => Notification.where('notifier_id = ? AND read_status = false', params[:user_id]).order(created_at: :desc)
  end

  # GET /read_notifications?user_id=1
  def read_notifications
    render :json => Notification.where('notifier_id = ? AND read_status = true', params[:user_id]).order(created_at: :desc).limit(params[:item_count])
  end

  # PUT /mark_notification_as_read/1
  def mark_notification_as_read
    Notification.find(params[:id]).update(read_status: true)
  end

  # PUT /mark_all_notifications_as_read?user_id=1
  def mark_all_notifications_as_read
    unread_notifications = Notification.where('notifier_id = ? AND read_status = false', params[:user_id])
    unread_notifications.update_all(read_status: true)
    render :json => {status: 'success'}
  end
end
