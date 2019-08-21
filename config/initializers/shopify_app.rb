ShopifyApp.configure do |config|
  config.application_name = "Seko OmniReturns"
  config.api_key = "0deac70618ffaca41aac840bd1303b23"
  config.secret = "3a5bc5c00ef055726a059c0a0e077396"
  config.old_secret = "<old_secret>"
  # Consult this page for more scope options: https://help.shopify.com/en/api/getting-started/authentication/oauth/scopes
  # read_gift_cards, write_gift_cards, read_script_tags, write_script_tags
  config.scope = "read_customers, read_products, read_orders, write_orders"
  config.embedded_app = true
  config.after_authenticate_job = false
  config.api_version = "2019-04"
  config.session_repository = Shop
  # config.webhooks = [
    # {topic: 'orders/create', address: 'https://test.omnirps.com/webhook/create_order_webhook', format: 'json'},
  # ]
end
