# frozen_string_literal: true

class WebhookController < ApplicationController
    # disable the CSRF protection
    skip_before_action :verify_authenticity_token

    # Index action
    def index
        @params = params
        render :json => @params
    end

    # Uninstall App
    def uninstall_app
        @params = params
        current_shop_domain = headers["X-Shopify-Shop-Domain"]
        if current_shop_domain.nil?
            current_shop_domain = request.headers["X-Shopify-Shop-Domain"]
        end
        shop = Shop.find_by(shopify_domain: current_shop_domain)
        shop_settings = ShopSetting.find_by(shop_id: shop.id)
        unless shop.nil?
            # Remove shop related settings
            unless shop_settings.nill?
                # Create Shopify API session
                session = ShopifyAPI::Session.new(domain: shop['shopify_domain'], token: shop['shopify_token'], api_version: "2019-04")
                # Activate shopify new session
                ShopifyAPI::Base.activate_session(session)
                # Delete webhooks
                ShopifyAPI::Webhook.delete(shop_settings['create_order_webhook_id'])
                ShopifyAPI::Webhook.delete(shop_settings['uninstall_app_webhook_id'])
            end
            # Remove shop related data from database data
            ProductExclusionTag.find_by(shop_id: shop.id).destroy
            ShopReason.find_by(shop_id: shop.id).destroy
            Reason.find_by(shop_id: shop.id).destroy
            Rule.find_by(shop_id: shop.id).destroy
            RuleOption.find_by(shop_id: shop.id).destroy
            ShopSetting.find_by(shop_id: shop.id).destroy
            Shop.find_by(id: shop.id).destroy
        end
        # render :json => @params
    end

    # Test action
    def test
        @params = params
        # render :json => @params
        require 'httparty'
        require 'json'
        # url = 'http://example.com/resource'
        url = @@omnirps_check_retailer_available_url
        response = HTTParty.get(url)
        # response.parsed_response
        # render :json => JSON.parse(response.body)
        # Set header variables
        @request_headers = request.headers
        @only_headers = headers
    end

end