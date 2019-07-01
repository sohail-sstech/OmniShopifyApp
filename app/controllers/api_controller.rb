# frozen_string_literal: true

class ApiController < ApplicationController
  # disable the CSRF protection
  skip_before_action :verify_authenticity_token

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
        @response["Message"] = "You have successfully got the order data."
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

  # get shop settings data by using shop domain
  def get_shop_settings_data(shop_url='')
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
    shop_settings = Hash.new
    shop_settings['shop_product_exclusion_tags'] = shop_product_exclusion_tags.tag
    shop_settings['shop_reasons'] = shop_reasons
    shop_settings['shop_rules'] = shop_rules
    return shop_settings
  end

  # Get shop settings data
  # api/get_shop_settings
  # @shop
  def get_shop_settings
    @params = params
    shop_url = params[:shop]
    @shop_settings = Hash.new
    @shop_settings = self.get_shop_settings_data(shop_url)
    render :json => @shop_settings
  end

  # Get product data
  # api/get_product_data
  # @shop
  # @product_id
  def get_product_data
    shop_url = params[:shop]
    product_id = params[:product_id]
    @response = Hash.new
    if !product_id.nil? && !product_id.empty? && !shop_url.nil? && !shop_url.empty?
      # Get shop data
      get_shop_data = Shop.where(shopify_domain: shop_url).first
      #Check shop data available in database
      if !get_shop_data.nil?
        # Create Shopify API session
        session = ShopifyAPI::Session.new(domain: get_shop_data['shopify_domain'], token: get_shop_data['shopify_token'], api_version: "2019-04")
        
        # Activate shopify new session
        ShopifyAPI::Base.activate_session(session)
        
        # Get shopify order data
        product_data = ShopifyAPI::Product.find(product_id)
        # product_data = ShopifyAPI::Variant.where(sku: 'QF0000000008').first

        @response["Success"] = 1
        @response["Message"] = "You have successfully got the product data."
        @response["Data"] = product_data
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

  # Check rule conditions
  def check_rule_conditions(cond_field_value, cond_param, cond_value, order_data)
    return_val=0
    if cond_param == 'IET'
      if cond_field_value == 'OC'
        if order_data['shipping_address']['country_code'] == cond_value
          return_val = 1
        end
      elsif cond_field_value == 'ORR'
        if params[:ReturnReason] == cond_value
          return_val = 1
        end
      end
    elsif cond_param == 'INET'
      if cond_field_value == 'OC'
        if order_data['shipping_address']['country_code'] != cond_value
          return_val = 1
        end
      elsif cond_field_value == 'ORR'
        if params[:ReturnReason] != cond_value
          return_val = 1
        end
      end
    elsif cond_param == 'GT'
      if cond_field_value == 'OV'
        if order_data['total_price'] > cond_value
          return_val = 1
        end
      elsif cond_field_value == 'ODV'
        if order_data['total_discount'] > cond_value
          return_val = 1
        end
      elsif cond_field_value == 'ODP'
        discount_per = (order_data['total_discount']*100)/order_data['total_price'];
        if discount_per > cond_value
          return_val = 1
        end
      end
    elsif cond_param == 'LT'
      if cond_field_value == 'OV'
        if order_data['total_price'] < cond_value
          return_val = 1
        end
      elsif cond_field_value == 'ODV'
        if order_data['total_discount'] < cond_value
          return_val = 1
        end
      elsif cond_field_value == 'ODP'
        discount_per = (order_data['total_discount']*100)/order_data['total_price'];
        if discount_per < cond_value
          return_val = 1
        end
      end
    elsif cond_param == 'GTET'
      if cond_field_value == 'OV'
        if order_data['total_price'] >= cond_value
          return_val = 1
        end
      elsif cond_field_value == 'ODV'
        if order_data['total_discount'] >= cond_value
          return_val = 1
        end
      elsif cond_field_value == 'ODP'
        discount_per = (order_data['total_discount']*100)/order_data['total_price'];
        if discount_per >= cond_value
          return_val = 1
        end
      end
    elsif cond_param == 'LTET'
      if cond_field_value == 'OV'
        if order_data['total_price'] <= cond_value
          return_val = 1
        end
      elsif cond_field_value == 'ODV'
        if order_data['total_discount'] <= cond_value
          return_val = 1
        end
      elsif cond_field_value == 'ODP'
        discount_per = (order_data['total_discount']*100)/order_data['total_price'];
        if discount_per <= cond_value
          return_val = 1
        end
      end
    elsif cond_param == 'ET'
      if cond_field_value == 'OV'
        if order_data['total_price'] == cond_value
          return_val = 1
        end
      elsif cond_field_value == 'ODV'
        if order_data['total_discount'] == cond_value
          return_val = 1
        end
      elsif cond_field_value == 'ODP'
        discount_per = (order_data['total_discount']*100)/order_data['total_price'];
        if discount_per == cond_value
          return_val = 1
        end
      end
    end
    #return boolean value
    return return_val
  end

  # Make refund to the customer
  # api/refund_order_product_to_customer
  # @shop
  # @sample_request_str = {"OrderNo":"1001","ShopifyOrderId":"971253973055","ShopifyShopDomain":"gozti.myshopify.com","ReturnReason":"Found Better Price","RefundItems":[{"ShopifyOrderLineItemId":"2218298572863","ShopifyOrderProductId":"15275157356607","ShopifyOrderVariantId":"1892575608895","ItemSku":"GT0000000001","ReturnReason":"Found Better Price","ItemQuantity":"1"}]}
  def refund_order_product_to_customer
    @params = params
    shop_url = params[:shop]
    @response = Hash.new
    
    shop_settings = Hash.new
    shop_settings = self.get_shop_settings_data(shop_url)

    if !shop_url.nil? && !shop_url.empty?
      # Get shop data
      get_shop_data = Shop.where(shopify_domain: shop_url).first
      #Check shop data available in database
      if !get_shop_data.nil?
        # Create Shopify API session
        session = ShopifyAPI::Session.new(domain: get_shop_data['shopify_domain'], token: get_shop_data['shopify_token'], api_version: "2019-04")
        
        # Activate shopify new session
        ShopifyAPI::Base.activate_session(session)
        
        unless params[:ShopifyOrderId].nil?
          order_data = ShopifyAPI::Order.find(:first, {id: params[:ShopifyOrderId]})
        else
          order_data = ShopifyAPI::Order.find(:first, {order_number: params[:OrderNo]})
        end        
        refund = 1 # 1 = Refund, 2 = Store Credit
        is_return_shipping_fee = 0
        unless shop_settings['shop_rules'].nil?
          shop_settings['shop_rules'].each do |rule|
            rule_applied = false
            unless rule['cond_field'].nil?
              i=0
              false_cond_count=0;
              true_cond_count=0;
              rule['cond_field'].each do |cond_field|
                check_cond = self.check_rule_conditions(cond_field, rule['cond_param'][i], rule['cond_value'][i], order_data)
                if check_cond == 1
                  true_cond_count += 1;
                else
                  false_cond_count += 0;
                end
                i += 1
              end
              if true_cond_count > 0 || false_cond_count > 0
                is_return_shipping_fee = rule['return_shipping_fee'];
                rule_applied = true                
              else
                rule_applied = false
              end
              if true_cond_count > 0 && false_cond_count == 0
                refund = rule['refund_method'];
              end
            else
              rule_applied = false
            end
            if rule_applied == true
              break
            end
          end
        else
          refund = 1
        end        
      end
    end

    # refund = 2
    # Apply Gift Card to Customer
    if refund == 2
      store_credit_call = Hash.new
      gift_card_arr = Array.new
      order_data.line_items.each do |line_item|
        gift_card_hash = Hash.new
        number = 20
        charset = Array('A'..'Z')
        gift_card_code = Array.new(number) { charset.sample }.join
        gift_card_hash['code'] = gift_card_code
        gift_card_hash['currency'] = order_data.currency
        gift_card_hash['customer_id'] = order_data.customer.id
        gift_card_hash['order_id'] = order_data.id    
        gift_card_hash['line_item_id'] = line_item.id
        line_item_amount = line_item.price_set.presentment_money.amount;
        line_item_tax_amount = 0
        line_item.tax_lines.each do |tax_amount|
          line_item_tax_amount = line_item_tax_amount.to_f + tax_amount.price_set.presentment_money.amount.to_f
        end
        gift_card_hash['initial_value'] = line_item_amount.to_f + line_item_tax_amount.to_f
        ### store_credit_call = ShopifyAPI::GiftCard.create(gift_card_hash)
        gift_card_arr.push(gift_card_hash)
      end
      @response["Success"] = 1
      @response["Type"] = 'gift_card'
      @response["Message"] = "Called Gift Card Admin API."
      @response["Data"] = store_credit_call
      # render :json => gift_card_arr
    # Apply Refund to The Customer
    else
      refund_order_call = Hash.new
      refund_hash = Hash.new
      refund_hash['currency'] = order_data.currency
      refund_hash['notify'] = true
      refund_hash['note'] = params[:ReturnReason]
      if is_return_shipping_fee == 1
        shipping = Hash["full_refund" => true]
      else
        shipping = Hash["full_refund" => false]
      end
      refund_hash['shipping'] = shipping
      j=0;
      refund_line_items = Array.new
      params[:RefundItems].each do |item|
        temp_line = Hash.new
        temp_line['line_item_id'] = item['ShopifyOrderLineItemId']
        temp_line['quantity'] = item['ItemQuantity']
        temp_line['restock_type'] = false
        refund_line_items.push(temp_line);
        j += 1
      end
      refund_hash['refund_line_items'] = refund_line_items
      ### refund_order_call = order_data::Refund.create(refund_hash);
      # render :json => refund_hash
      @response["Success"] = 1
      @response["Type"] = 'refund'
      @response["Message"] = "Called Order Refund Admin API."
      @response["Data"] = refund_order_call
    end
    render :json => @response
  end

  # This action is for test
  def test
    @params = params
    # @shop = defined?(ShopifyAPI);
    # @order_no = params[:order_no]
    # @shop_url = params[:shop]
    shop_url = 'gozti.myshopify.com';
    # get shop data by shop URL
    get_shop_data = Shop.where(shopify_domain: shop_url).first
    # Create Shopify API session
    session = ShopifyAPI::Session.new(domain: get_shop_data['shopify_domain'], token: get_shop_data['shopify_token'], api_version: "2019-04")
    # session = ShopifyAPI::Session.new(domain: "queuefirst.myshopify.com", token: "4a6fdfd48b3d17639994e2f39d9bd8bd", api_version: "2019-04")
    # products = ShopifyAPI::Session.temp("queuefirst.myshopify.com", "4a6fdfd48b3d17639994e2f39d9bd8bd") { ShopifyAPI::Product.find(:all) }
    ShopifyAPI::Base.activate_session(session)

    @products = ShopifyAPI::Product.find(:all, {id: 1892575608895})
    # @products_metafield = ShopifyAPI::Metafield.find(:all, :params=>{:resource => "products", :resource_id => 1892575608895})
    @products_metafield = ShopifyAPI::Metafield.find(:all)
    # Render JSON
    # render :json => @products_metafield

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
    @specific_order = ShopifyAPI::Order.find(:all, params: { order_number: '1001', :limit => 1, :order => "created_at ASC"}).to_json
    render :json => @specific_order

    # Shops list from database
    @shops = Shop.all.to_json

    # Specific shop from database
    @specific_shop = Shop.where(shopify_domain: "queuefirst.myshopify.com").first.to_json

    # Get shop data
    @get_shop_data = Shop.where(shopify_domain: "queuefirst.myshopify.com").first
    
  end
end
