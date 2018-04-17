# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version - 2.5.1

* Rails version - 5.2.0

* System dependencies - has_scope, devise_token_auth

* Configuration - puma (cluster mode)

* Database creation - 
    rails db:drop
    rails db:create
    rails db:migrate
    rails db:seed

* Services (job queues, cache servers, search engines, etc.) - None

* Deployment instructions
    - puma -C config/puma.rb -d
    - RAILS_ENV=production rails db:drop DISABLE_DATABASE_ENVIRONMENT_CHECK=1
