ShopifyApp.configure do |config|
  config.application_name = "My Shopify App"
  config.api_key = "64f39020a290ada7b5d2b39c673047f0"
  config.secret = "271f01ed825156d5819dda8e03db3666"
  config.old_secret = "<old_secret>"
  config.scope = "read_customers, read_products, read_orders, write_orders, read_script_tags, write_script_tags" # Consult this page for more scope options:
                                 # https://help.shopify.com/en/api/getting-started/authentication/oauth/scopes
  config.embedded_app = true
  config.after_authenticate_job = false
  config.api_version = "2019-04"
  config.session_repository = Shop
end
