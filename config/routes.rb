Rails.application.routes.draw do
  root :to => 'home#index'
  mount ShopifyApp::Engine, at: '/'
  get "home/test", :to => 'home#test'
  get "home/create_order_webhook", :to => 'home#create_order_webhook'
  get "home/remove_webhook/:webhook_id", :to => 'home#remove_webhook'  
  get "product_exclusion_tags", :to => 'settings#product_exclusion_tags'
  post "product_exclusion_tags", :to => 'settings#product_exclusion_tags'
  post "submit_product_exclusion_tags", :to => 'settings#submit_product_exclusion_tags'
  get "return_reasons", :to => 'settings#return_reasons'
  post "submit_return_reasons", :to => 'settings#submit_return_reasons'
  get "add_reasons", :to => 'settings#add_new_return_reason'
  post "submit_add_reasons", :to => 'settings#submit_add_new_return_reason'
  delete "remove_shop_reason/:id", to: "settings#remove_shop_reason"
  get "rules", :to => 'settings#rules'
  get "select_rule", :to => 'settings#select_rule'
  get "create_rule/:rule_type", to: 'settings#create_rule' # @rule_type 1 = Country, 2 = Order Value, 3 = Order Discount, 4 = Return Reason
  post "submit_create_rule/:rule_type", to: 'settings#submit_create_rule'
  get "update_rule/:id", to: 'settings#update_rule'
  post "submit_update_rule/:id", to: 'settings#submit_update_rule'
  delete "remove_rule/:id", to: "settings#remove_rule"
  get "add_options_to_rule/:rule_id", to: 'settings#add_options_to_rule'
  post "submit_add_options_to_rule/:rule_id", to: 'settings#submit_add_options_to_rule'
  get "update_options_to_rule/:id", to: 'settings#update_options_to_rule'
  post "submit_update_options_to_rule/:id", to: 'settings#submit_update_options_to_rule'
  delete "remove_rule_option/:id", to: "settings#remove_rule_option"
  get "api/index", :to => 'api#index'
  get "api/test", :to => 'api#test'
  get "api/get_order_data", :to => 'api#get_order_data'
  post "api/get_order_data", :to => 'api#get_order_data'
  get "api/get_shop_settings", :to => 'api#get_shop_settings'
  post "api/get_shop_settings", :to => 'api#get_shop_settings'
  get "api/get_product_data", :to => 'api#get_product_data'
  post "api/get_product_data", :to => 'api#get_product_data'
  get "api/refund_order_product_to_customer", :to => 'api#refund_order_product_to_customer'
  post "api/refund_order_product_to_customer", :to => 'api#refund_order_product_to_customer'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end