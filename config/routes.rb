Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  resources :users
  resources :items

  resources :companies
  get 'companies/:id/last_created_invoice' => 'companies#last_created_invoice'

  resources :customers
  get 'customers/:id/last_created_invoice' => 'customers#last_created_invoice'

  resources :invoices
  get 'recent_invoices' => 'invoices#recent_invoices'
end
