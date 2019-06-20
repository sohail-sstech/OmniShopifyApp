# frozen_string_literal: true

class ApiController < ApplicationController
  def index
    shop_url = params[:shop_url]
    order_no = params[:order_no]
    @response = Hash.new
    if !order_no.nil? && !order_no.empty? && !shop_url.nil? && !shop_url.empty?
      # Get shop data
      get_shop_data = Shop.where(shopify_domain: shop_url).first
      #Check shop data available in database
      if !get_shop_data.nil?
        # Create Shopify API session
        session = ShopifyAPI::Session.new(domain: get_shop_data['shopify_domain'], token: get_shop_data['shopify_token'], api_version: "2019-04")
        
        # Activate shopify new session
        ShopifyAPI::Base.activate_session(session)
        
        # Get shopify order data
        order_data = ShopifyAPI::Order.find(:all, params: { order_number: order_no, :limit => 1, :order => "created_at ASC"})

        @response["Success"] = 1
        @response["Message"] = "You have successfully got the data."
        @response["Data"] = order_data
      else
        @response["Success"] = 0
        @response["Message"] = "Something went wrong!"
        @response["Data"] = ""
      end
    else
      @response["Success"] = 0
      @response["Message"] = "Something went wrong!"
      @response["Data"] = ""
    end

    # Convert Hash value to JSON
    @response = @response.to_json
  end

  def test
    # @shop = defined?(ShopifyAPI);
    @order_no = params[:order_no]
    @shop_url = params[:shop]
    # Rails.logger.debug("Order No: #{@order_no}")
    session = ShopifyAPI::Session.new(domain: "queuefirst.myshopify.com", token: "4a6fdfd48b3d17639994e2f39d9bd8bd", api_version: "2019-04")
    # products = ShopifyAPI::Session.temp("queuefirst.myshopify.com", "4a6fdfd48b3d17639994e2f39d9bd8bd") { ShopifyAPI::Product.find(:all) }
    ShopifyAPI::Base.activate_session(session)

=begin
    @shop = ShopifyAPI::Shop.current

    # Get all products
    @products = ShopifyAPI::Product.find(:all)

    # Get all orders
    @orders = ShopifyAPI::Order.find(:all)

    # Get all orders
    @orders = ShopifyAPI::Order.find(:all)
=end

    # Fetch all countries data
    @all_countries = ShopifyAPI::Country.find(:all, params: {}).to_json

    # Specific order from shopify store
    @specific_order = ShopifyAPI::Order.find(:all, params: { order_number: '1038', :limit => 1, :order => "created_at ASC"}).to_json

    # Shops list from database
    @shops = Shop.all.to_json

    # Specific shop from database
    @specific_shop = Shop.where(shopify_domain: "queuefirst.myshopify.com").first.to_json

    # Get shop data
    @get_shop_data = Shop.where(shopify_domain: "queuefirst.myshopify.com").first
    
  end
end
