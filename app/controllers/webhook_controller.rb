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
        @response = Hash.new
        current_shop_domain = params[:shop]
        if current_shop_domain.nil?
            current_shop_domain = headers["X-Shopify-Shop-Domain"]
        end
        if current_shop_domain.nil?
            current_shop_domain = request.headers["X-Shopify-Shop-Domain"]
        end
        shop = Shop.find_by(shopify_domain: current_shop_domain)
        shop_settings = ShopSetting.find_by(shop_id: shop.id)
        unless shop.nil?
            # Remove shop related settings
            unless shop_settings.nil?
                # Create Shopify API session
                session = ShopifyAPI::Session.new(domain: shop['shopify_domain'], token: shop['shopify_token'], api_version: "2019-04")
                # Activate shopify new session
                ShopifyAPI::Base.activate_session(session)
                # Delete webhooks
                unless shop_settings['create_order_webhook_id'].nil?
                    # create_order_webhook_data = ShopifyAPI::Webhook.find(:all, :params => {:id => shop_settings['create_order_webhook_id']} )
                    # unless create_order_webhook_data.nil?
                    if ShopifyAPI::Webhook.find(shop_settings['create_order_webhook_id']).any?
                        ShopifyAPI::Webhook.delete(shop_settings['create_order_webhook_id'])
                    end
                end
                unless shop_settings['uninstall_app_webhook_id'].nil?
                    # uninstall_app_webhook_data = ShopifyAPI::Webhook.find(:all, :params => {:id => shop_settings['uninstall_app_webhook_id']} )
                    # unless uninstall_app_webhook_data.nil?
                    if ShopifyAPI::Webhook.find(shop_settings['uninstall_app_webhook_id']).any?
                        ShopifyAPI::Webhook.delete(shop_settings['uninstall_app_webhook_id'])
                    end
                end
            end
            # Remove shop related data from database data
            product_exclusion_tag = ProductExclusionTag.where("shop_id = ?", shop.id)
            if product_exclusion_tag.count > 0
                product_exclusion_tag.destroy_all
            end
            shop_reason = ShopReason.where("shop_id = ?", shop.id)
            if shop_reason.count > 0
                shop_reason.destroy_all
            end
            reason = Reason.where("shop_id = ?", shop.id)
            if reason.count > 0
                reason.destroy_all
            end
            rule = Rule.where("shop_id = ?", shop.id)
            if rule.count > 0
                rule.destroy_all
            end
            rule_option = RuleOption.where("shop_id = ?", shop.id)
            if rule_option.count > 0
                rule_option.destroy_all
            end
            shop_setting_data = ShopSetting.where("shop_id = ?", shop.id)
            if shop_setting_data.count > 0
                shop_setting_data.destroy_all
            end
            shop_data = Shop.where("id = ?", shop.id)
            if shop_data.count > 0
                shop_data.destroy_all
            end
            # ProductExclusionTag.find_by(shop_id: shop.id).destroy
            # ShopReason.find_by(shop_id: shop.id).destroy
            # Reason.find_by(shop_id: shop.id).destroy
            # Rule.find_by(shop_id: shop.id).destroy
            # RuleOption.find_by(shop_id: shop.id).destroy
            # ShopSetting.find_by(shop_id: shop.id).destroy
            # Shop.find_by(id: shop.id).destroy
            @response["Success"] = 1
            @response["Message"] = "Successfylly uninstalled the Shopify App."
        end
        render :json => @response
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