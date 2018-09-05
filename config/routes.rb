Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', skip: [:omniauth_callbacks]
  resources :users
  resources :items

  resources :companies
  get 'companies/:id/last_created_invoice' => 'companies#last_created_invoice'

  resources :customers
  get 'customers/:id/last_created_invoice' => 'customers#last_created_invoice'
  get 'customers/:id/last_five_ordered_items' => 'customers#last_five_ordered_items'
  get 'customers/:id/invoice_sample_comments' => 'customers#invoice_sample_comments'

  resources :invoices
  get 'recent_invoices' => 'invoices#recent_invoices'
  get 'invoices_between' => 'invoices#invoices_between'
  get 'previous_and_next_invoice' => 'invoices#previous_and_next_invoice'
  get 'previous_ordered_item_search_for_customer' => 'invoices#previous_ordered_item_search_for_customer'
  get 'past_invoices' => 'invoices#past_invoices'

  resources :statistics
end
