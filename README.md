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
    - Edit credentials : 'EDITOR="nano" bin/rails credentials:edit'
    - bundle exec sidekiq -L log/sidekiq.log -d -e production
    - sudo service nginx start
    
* Renew SSL certificate from Let's encrypt
    - sudo certbot delete
    - sudo certbot certonly --manual  -d *.jkaromaticsandperfumers.online -d jkaromaticsandperfumers.online --preferred-challenges dns-01 --server https://acme-v02.api.letsencrypt.org/directory    
    
* Backup production DB
    - pg_dump -U ubuntu -f jkbackup.dump jkstocktake -Ft --pass
    
* Restore/copy production DB to local
    - sudo scp -i "jk-mac.pem" ubuntu@13.126.46.210:/home/ubuntu/jkbackup.dump ./
    - pg_restore -d jkstocktake -U postgres -C jkbackup.dump --no-acl