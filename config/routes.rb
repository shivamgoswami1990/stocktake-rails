Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', skip: [:omniauth_callbacks]
  resources :users
  patch 'change_user_password' => 'users#change_user_password'

  resources :items

  resources :companies
  get 'companies/:id/last_created_invoice' => 'companies#last_created_invoice'

  resources :customers
  get 'customers/:id/last_created_invoice' => 'customers#last_created_invoice'
  get 'customers/:id/all_ordered_items' => 'customers#all_ordered_items'
  get 'customers/:id/invoice_sample_comments' => 'customers#invoice_sample_comments'
  get 'customers/:id/invoice_count' => 'customers#invoice_count'

  resources :invoices
  get 'recent_invoices' => 'invoices#recent_invoices'
  get 'invoices_between' => 'invoices#invoices_between'
  get 'previous_and_next_invoice' => 'invoices#previous_and_next_invoice'
  get 'previous_ordered_item_search_for_customer' => 'invoices#previous_ordered_item_search_for_customer'
  get 'past_invoices' => 'invoices#past_invoices'
  post 'historical_data' => 'invoices#historical_data'
  get 'hsn_summary_by_date' => 'invoices#hsn_summary_by_date'
  get 'invoice_list' => 'invoices#invoice_list'
  get 'extract_items' => 'invoices#extract_items'

  get 'unread_notifications' => 'notifications#unread_notifications'
  get 'read_notifications' => 'notifications#read_notifications'
  get 'unread_notification_count' => 'notifications#unread_notification_count'
  get 'invoice_notifications' => 'notifications#invoice_notifications'
  put 'mark_notification_as_read' => 'notifications#mark_notification_as_read'
  put 'mark_all_notifications_as_read' => 'notifications#mark_all_notifications_as_read'

  resources :statistics
  resources :ordered_items
  get 'all_ordered_items' => 'ordered_items#all_ordered_items'

  resources :transports

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
