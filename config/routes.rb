Rails.application.routes.draw do
  root :to => 'home#index'
  mount ShopifyApp::Engine, at: '/'
  get "home/test", :to => 'home#test'
  get "home/create_order_webhook", :to => 'home#create_order_webhook'
  get "home/remove_webhook", :to => 'home#remove_webhook'
  get "api/index", :to => 'api#index'
  get "api/test", :to => 'api#test'
  get "product_exclusion_tags", :to => 'settings#product_exclusion_tags'
  post "product_exclusion_tags", :to => 'settings#product_exclusion_tags'
  post "submit_product_exclusion_tags", :to => 'settings#submit_product_exclusion_tags'
  get "return_reasons", :to => 'settings#return_reasons'
  post "submit_return_reasons", :to => 'settings#submit_return_reasons'
  get "add_reasons", :to => 'settings#add_new_return_reason'
  post "submit_add_reasons", :to => 'settings#submit_add_new_return_reason'
  get "rules", :to => 'settings#rules'
  get "select_rule", :to => 'settings#select_rule'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end