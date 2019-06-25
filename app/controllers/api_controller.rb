# frozen_string_literal: true

class ApiController < ApplicationController
  
  # index action
  def index
    @params = params
  end

  # get shop order data by using shop url and order no
  # api/get_order_data
  # @shop i.e. queuefirst.myshopify.com
  # @order_no i.e. 1038
  def get_order_data
    shop_url = params[:shop]
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
    @response = @response
    # Render JSON data
    render :json => @response
  end

  # Get shop settings data
  # api/get_shop_settings
  # @shop
  def get_shop_settings
    @params = params
    shop_url = params[:shop]
    # Get shop data
    get_shop_data = Shop.where(shopify_domain: shop_url).first
    shop_id = get_shop_data.id
    # Get shop data
    shop_product_exclusion_tags = ProductExclusionTag.select("id, tag").find_by(shop_id: shop_id)
    shop_reason_ids_data = ShopReason.find_by(shop_id: shop_id)
    unless shop_reason_ids_data.nil?
      shop_reasons = Reason.select("id, reason").where(id: JSON.parse(shop_reason_ids_data.reason_ids)).find_all
    else
      shop_reasons = Reason.select("id, reason").find_all
    end
    shop_rules_data = Rule.select("rules.id, rules.id as rule_id, rules.name, rules.priority, rules.conditions, rule_options.id as rule_option_id, rule_options.refund_method, rule_options.return_window, rule_options.return_shipping_fee").joins("LEFT JOIN rule_options ON rule_options.rule_id = rules.id").where(shop_id: shop_id).order("rules.priority ASC").find_all
    shop_rules = Array.new
    i = 0
    shop_rules_data.each do |rule|
      tmp_hash = Hash.new
      tmp_hash['rule_id'] = rule.id
      tmp_hash['name'] = rule.name
      tmp_hash['priority'] = rule.priority
      tmp_hash['conditions'] = JSON.parse(rule.conditions)
      tmp_hash['rule_option_id'] = rule.rule_option_id
      tmp_hash['refund_method'] = rule.refund_method
      tmp_hash['return_window'] = rule.return_window
      tmp_hash['return_shipping_fee'] = rule.return_shipping_fee
      shop_rules[i] = tmp_hash
      i = i + 1;
    end
    @shop_settings = Hash.new
    @shop_settings['shop_product_exclusion_tags'] = shop_product_exclusion_tags.tag
    @shop_settings['shop_reasons'] = shop_reasons
    @shop_settings['shop_rules'] = shop_rules
    render :json => @shop_settings
  end

  # This action is for test
  def test
    @params = params
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
