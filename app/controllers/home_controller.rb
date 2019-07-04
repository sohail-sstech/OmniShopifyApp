# frozen_string_literal: true

class HomeController < AuthenticatedController

  # Index action
  def index
    @params = params
    # @products = ShopifyAPI::Product.find(:all, params: { limit: 10 })
    current_shop_domain = ShopifyAPI::Shop.current.domain
    shop = Shop.find_by(shopify_domain: current_shop_domain)
    shop_settings = ShopSetting.find_by(shop_id: shop.id)
    unless shop_settings.nil?
      @webhooks = ShopifyAPI::Webhook.find(:all)
    else
      render "update_shop_settings.html.erb"
    end
  end

  # Submit update shop settings
  def submit_update_shop_settings
    @params = params
    current_shop_domain = ShopifyAPI::Shop.current.domain
    shop = Shop.find_by(shopify_domain: current_shop_domain)
    if params[:token].nil? || params[:token].empty?
        @errors_messages = Array["Error! Please enter Access Token."]
    else
        require 'httparty'
        require 'json'
        url = 'https://test.omnirps.com/api/check_retailer_available'
        request_data = Hash.new
        request_data['Token'] = params[:token]
        request_data['ShopifyShopDomain'] = current_shop_domain
        request_headers = Hash.new
        response = HTTParty.get(url.to_str, :body => request_data.to_json, :headers => request_headers)
        response_data = JSON.parse(response.body)
        if !response_data['Success'].nil? && response_data['Success'] == 1
          # order create webhook
          order_create_wh = ShopifyAPI::Webhook.new({:topic => "orders/create", :address => "https://test.omnirps.com/webhook/create_order_webhook", :format => "json"})
          order_create_wh.save
          order_create_wh_id = order_create_wh["id"]
          # uninstall app webhook
          uninstall_app_wh = ShopifyAPI::Webhook.new({:topic => "app/uninstalled", :address => "https://eeb0675f.ngrok.io/webhook/uninstall_app", :format => "json"})
          uninstall_app_wh.save
          uninstall_app_wh_id = uninstall_app_wh["id"]
          # Save data to shop settings
          save_shop_setting = ShopSetting.create(shop_id: shop.id, token: params[:token], create_order_webhook_id: order_create_wh_id, uninstall_app_webhook_id: uninstall_app_wh_id)
          unless save_shop_setting.valid?
              ShopifyAPI::Webhook.delete(order_create_wh_id)
              ShopifyAPI::Webhook.delete(uninstall_app_wh_id)
              @errors_messages = save_shop_setting.errors[:token]
          else
            flash[:notice] = "Success! Shop Configuration Successfully updated."
            redirect_to '/'
          end
        else
          @errors_messages = Array["Error! Please enter a valid Access Token."]
        end
    end
    unless @errors_messages.nil?
      render "update_shop_settings.html.erb"
    end
  end

  # Reconfigure shop settings
  def reconfig_shop_settings
    @params = params
    current_shop_domain = ShopifyAPI::Shop.current.domain
    shop = Shop.find_by(shopify_domain: current_shop_domain)
    @shop_setting = ShopSetting.find_by(shop_id: shop.id)
    render "update_shop_settings.html.erb"
  end

  # Reconfigure shop settings
  def submit_reconfig_shop_settings
    @params = params
    current_shop_domain = ShopifyAPI::Shop.current.domain
    shop = Shop.find_by(shopify_domain: current_shop_domain)
    if params[:token].nil? || params[:token].empty?
        @errors_messages = Array["Error! Please enter Access Token."]
    else
        require 'httparty'
        require 'json'
        url = 'https://test.omnirps.com/api/check_retailer_available'
        request_data = Hash.new
        request_data['Token'] = params[:token]
        request_data['ShopifyShopDomain'] = current_shop_domain
        request_headers = Hash.new
        response = HTTParty.get(url.to_str, :body => request_data.to_json, :headers => request_headers)
        response_data = JSON.parse(response.body)
        if !response_data['Success'].nil? && response_data['Success'] == 1
          # Save data to shop settings
          shop_setting = ShopSetting.find_by(shop_id: shop.id)
          if shop_setting.nil?
            save_shop_setting = ShopSetting.create(token: params[:token])
          else
            save_shop_setting = ShopSetting.find_by(shop_id: shop.id)
            save_shop_setting.update(token: params[:token])
          end
          unless save_shop_setting.valid?
              @errors_messages = save_shop_setting.errors[:token]
          else
            flash[:notice] = "Success! Shop Configuration Successfully updated."
            redirect_to '/'
          end
        else
          @errors_messages = Array["Error! Please enter a valid Access Token."]
        end
    end
    unless @errors_messages.nil?
      @shop_setting = ShopSetting.find_by(shop_id: shop.id)
      render "update_shop_settings.html.erb"
    end
  end

  # Create order webhook
  def create_order_webhook
    new_webhook = ShopifyAPI::Webhook.new({:topic => "orders/create", :address => "https://test.omnirps.com/webhook/create_order_webhook", :format => "json"})
    new_webhook.save
    # @webhooks = ShopifyAPI::Webhook.find(:all)
    flash[:notice] = "Success! You have successfully created the webhook."
    redirect_to '/'
  end

  # Create uninstall app webhook
  def create_uninstall_app_webhook
    new_webhook = ShopifyAPI::Webhook.new({:topic => "app/uninstalled", :address => "https://e8b10886.ngrok.io/webhook/uninstall_app", :format => "json"})
    new_webhook.save
    # render :json => new_webhook
    # @webhooks = ShopifyAPI::Webhook.find(:all)
    flash[:notice] = "Success! You have successfully created the webhook."
    redirect_to '/'
  end

  # Remove webhook
  def remove_webhook
    webhook_id = params[:webhook_id]
    unless webhook_id.nil?
      ShopifyAPI::Webhook.delete(webhook_id)
      flash[:notice] = "Success! You have successfully deleted the webhook."
    else
      flash[:notice] = "Error! Something went wrong!"
    end
    redirect_to '/'
  end

  # Test action
  def test
    @params = params
=begin
    require 'net/http'
    require 'uri'

    url = 'http://localhost:3000/api/index'
    uri = URI.parse(url)

    params = {'message' => 'yes'}

    response = Net::HTTP.post_form(uri, params)
=end
  end
end
