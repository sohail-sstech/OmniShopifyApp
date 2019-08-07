class ApplicationController < ActionController::Base
    @@omnirps_check_retailer_available_url = 'https://test.omnirps.com/api/check_retailer_available'
    @@omnirps_create_order_webhook_url = 'https://test.omnirps.com/webhook/create_order_webhook'
    @@shopify_uninstall_app_webhook_url = 'https://6f683f84.ngrok.io/webhook/uninstall_app'
    
end
