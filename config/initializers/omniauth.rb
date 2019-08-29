Rails.application.config.middleware.use OmniAuth::Builder do
# frozen_string_literal: true

provider :shopify,
  ShopifyApp.configuration.api_key,
  ShopifyApp.configuration.secret,
  scope: ShopifyApp.configuration.scope,
  setup: lambda { |env|
    strategy = env['omniauth.strategy']

    shopify_auth_params = strategy.session['shopify.omniauth_params']&.with_indifferent_access
    shop = if shopify_auth_params.present?
      "https://#{shopify_auth_params[:shop]}"
    else
      ''
    end
	
	# strategy.options[:callback_url] = "https://1cbfc401.ngrok.io/auth/shopify/callback"
    strategy.options[:client_options][:site] = shop
    strategy.options[:old_client_secret] = ShopifyApp.configuration.old_secret
  }
end
