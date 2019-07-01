# class SettingsController < ApplicationController
class SettingsController < AuthenticatedController

    # Product exclusion tags action
    def product_exclusion_tags
        @params = params
        # params.permit(:shop_id, :exclusion_tags)
        exclusion_tags = params[:exclusion_tags]
        # if !exclusion_tags.nil?        
        current_shop_domain = ShopifyAPI::Shop.current.domain
        shop = Shop.find_by(shopify_domain: current_shop_domain)
        @shop_id = shop.id
        product_exclusion_tag = ProductExclusionTag.find_by(shop_id: shop.id)
        if product_exclusion_tag.nil?
            @no_tags = 'no-returns'
        else
            @no_tags = product_exclusion_tag.tag
        end
    end

    # Product exclusion tags action
    def submit_product_exclusion_tags
        @params = params
        # params.permit(:shop_id, :exclusion_tags)
        @exclusion_tags = params[:exclusion_tags]
        @shop_id = params[:shop_id]
        # redirect_to '/product_exclusion_tags'
        # shop = Shop.find_by(shopify_domain: current_shop_domain)
        product_exclusion_tag = ProductExclusionTag.find_by(shop_id: params[:shop_id])
        if product_exclusion_tag.nil?
            save_product_exclusion_tag = ProductExclusionTag.create(shop_id: params[:shop_id], tag: params[:exclusion_tags])
            unless save_product_exclusion_tag.valid?
                @errors_messages = save_product_exclusion_tag.errors[:tag]
            else
                flash[:notice] = "Success! Product exclusion tags have been successfully created."
            end
        else
            save_product_exclusion_tag = ProductExclusionTag.find_by(shop_id: params[:shop_id])
            save_product_exclusion_tag.update(tag: params[:exclusion_tags])
            unless save_product_exclusion_tag.valid?
                @errors_messages = save_product_exclusion_tag.errors[:tag]
            else
                flash[:notice] = "Success! Product exclusion tags have been successfully updated."
            end
        end
        # Reset data
        product_exclusion_tag = ProductExclusionTag.find_by(shop_id: params[:shop_id])
        if product_exclusion_tag.nil?
            @no_tags = 'no-returns'
        else
            @no_tags = product_exclusion_tag.tag
        end
        render "product_exclusion_tags"
    end

    # return reason action
    def return_reasons
        @params = params
        current_shop_domain = ShopifyAPI::Shop.current.domain
        shop = Shop.find_by(shopify_domain: current_shop_domain)
        @selected_reasons = params[:shop_reasons].to_json
        shop_id = shop.id
        @reasons = Reason.all
        @shop_reasons = ShopReason.find_by(shop_id: shop_id)
    end

     # return reason action
    def submit_return_reasons
        @params = params
        current_shop_domain = ShopifyAPI::Shop.current.domain
        shop = Shop.find_by(shopify_domain: current_shop_domain)
        @selected_reasons = params[:shop_reasons].to_json
        shop_id = shop.id
        selected_reasons = params[:shop_reasons].to_json        
        shop_reasons = ShopReason.find_by(shop_id: shop_id)
        if shop_reasons.nil?
            save_shop_reasons = ShopReason.create(shop_id: shop_id, reason_ids: selected_reasons)
            flash[:notice] = "Success! Shop reasons have been successfully updated."
        else
            save_shop_reasons = ShopReason.find_by(shop_id: shop_id)
            save_shop_reasons.update(reason_ids: selected_reasons)
            flash[:notice] = "Success! Shop reasons have been successfully updated."
        end
        @reasons = Reason.all
        @shop_reasons = ShopReason.find_by(shop_id: shop_id)
        render "return_reasons"
    end

    # return reason action
    def add_new_return_reason
        @params = params
    end

    # return reason action
    def submit_add_new_return_reason
        @params = params
        # @display = "above unless #{@params[:reason]}"
        # unless params[:reason].empty?
            # @display = "in unless #{@params[:reason]}"
            save_return_reason = Reason.create(reason: params[:reason])
            unless save_return_reason.valid?
                @errors_messages = save_return_reason.errors[:reason]
            else
                flash[:notice] = "Success! Shop reason has been successfully created."
            end
        # end
        render "add_new_return_reason"
    end

    # rules for return product
    def rules
        @params = params
        current_shop_domain = ShopifyAPI::Shop.current.domain
        shop = Shop.find_by(shopify_domain: current_shop_domain)
        shop_id = shop.id
        @cond_field_harr = {'OV' => 'Order Value', 'ODV' => 'Order Discount Value', 'ODP' => 'Order Discount Percent', 'OC' => 'Order Country', 'ORR' => 'Order Return Reason'};
        @cond_param_harr = {'GT' => 'Greater Than', 'LT' =>'Less Than', 'GTET' => 'Greater Than or Equal to', 'LTET' => 'Less Than or Equal to', 'ET' => 'Equal to',  'IET' => 'Is', 'INET' => 'Is Not'}
        
        country_data = Country.select("id, iso, nicename").find_all
        @country_harr = Hash.new
        country_data.each do |country|
            @country_harr[country.iso] = country.nicename
        end
        @rule_list = Rule.select("rules.id, rules.id as rule_id, rules.name, rules.priority, rules.conditions, rule_options.id as rule_option_id, rule_options.refund_method, rule_options.return_window, rule_options.return_shipping_fee").joins("LEFT JOIN rule_options ON rule_options.rule_id = rules.id").where(shop_id: shop_id).order("rules.priority ASC").find_all
    end

    # select rule type
    def select_rule
        @params = params
    end

    # create rule
    def create_rule
        @params = params
        current_shop_domain = ShopifyAPI::Shop.current.domain
        shop = Shop.find_by(shopify_domain: current_shop_domain)
        shop_id = shop.id
        @rule_priority_list = [['1', 1], ['2', 2], ['3', 3], ['4', 4], ['5', 5]];
        @cond_field_list = [['Order Value', 'OV'], ['Order Discount Value', 'ODV'], ['Order Discount Percent', 'ODP'], ['Order Country', 'OC'], ['Order Return Reason', 'ORR']];
        @cond_param_compare_list = [['Greater Than', 'GT'], ['Less Than', 'LT'], ['Greater Than or Equal to', 'GTET'], ['Less Than or Equal to', 'LTET'], ['Equal to', 'ET']];
        @cond_param_boolean_list = [['Is', 'IET'], ['Is Not', 'INET']];
        if params[:rule_type] == '1'
            selected_cond_filed = 'OC'
        elsif params[:rule_type] == '2'
            selected_cond_filed = 'OV'
        elsif params[:rule_type] == '3'
            selected_cond_filed = 'ODP'
        elsif params[:rule_type] == '4'
            selected_cond_filed = 'ORR'
        else
            selected_cond_filed = 'OV'
        end
        @selected_cond_filed = selected_cond_filed
        # @country_list = [['United States', 'US'], ['United Kingdom', 'UK'], ['Australia', 'AU'], ['New Zealand', 'NZ'], ['India', 'IN']];
        country_data = Country.select("id, iso, nicename").find_all
        @country_list = Array.new
        i = 0;
        country_data.each do |country|
            @country_list[i] = [country.nicename, country.iso]
            i += 1;
        end
        # @country_list = country_list;
        @reason_list = [['Size - Too Small', 'Size - Too Small'], ['Size - Too Large', 'Size - Too Large'], ['Style', 'Style'], ['Color', 'Color'], ['Too Expensive', 'Too Expensive']];
        shop_reason_ids_data = ShopReason.select("id, shop_id, reason_ids").find_by(shop_id: shop_id)
        unless shop_reason_ids_data.nil?
            shop_reason_data = Reason.select("id, reason").where(id: JSON.parse(shop_reason_ids_data.reason_ids)).find_all
        else
            shop_reason_data = Reason.select("id, reason").find_all
        end
        # @shop_reason_ids_data = shop_reason_ids_data
        # @shop_reason_data = shop_reason_data
        @reason_list = Array.new
        i = 0;
        shop_reason_data.each do |shop_reason|
            @reason_list[i] = [shop_reason.reason, shop_reason.reason]
            i += 1;
        end
    end

    # save rule
    def submit_create_rule
        @params = params
        current_shop_domain = ShopifyAPI::Shop.current.domain
        shop = Shop.find_by(shopify_domain: current_shop_domain)
        shop_id = shop.id
        @rule_priority_list = [['1', 1], ['2', 2], ['3', 3], ['4', 4], ['5', 5]];
        @cond_field_list = [['Order Value', 'OV'], ['Order Discount Value', 'ODV'], ['Order Discount Percent', 'ODP'], ['Order Country', 'OC'], ['Order Return Reason', 'ORR']];
        @cond_param_compare_list = [['Greater Than', 'GT'], ['Less Than', 'LT'], ['Greater Than or Equal to', 'GTET'], ['Less Than or Equal to', 'LTET'], ['Equal to', 'ET']];
        @cond_param_boolean_list = [['Is', 'IET'], ['Is Not', 'INET']];
        if params[:rule_type] == '1'
            selected_cond_filed = 'OC'
        elsif params[:rule_type] == '2'
            selected_cond_filed = 'OV'
        elsif params[:rule_type] == '3'
            selected_cond_filed = 'ODP'
        elsif params[:rule_type] == '4'
            selected_cond_filed = 'ORR'
        else
            selected_cond_filed = 'OV'
        end
        @selected_cond_filed = selected_cond_filed
        # @country_list = [['United States', 'US'], ['United Kingdom', 'UK'], ['Australia', 'AU'], ['New Zealand', 'NZ'], ['India', 'IN']];
        country_data = Country.select("id, iso, nicename").find_all
        @country_list = Array.new
        i = 0;
        country_data.each do |country|
            @country_list[i] = [country.nicename, country.iso]
            i += 1;
        end
        # @country_list = country_list;
        @reason_list = [['Size - Too Small', 'Size - Too Small'], ['Size - Too Large', 'Size - Too Large'], ['Style', 'Style'], ['Color', 'Color'], ['Too Expensive', 'Too Expensive']];
        shop_reason_ids_data = ShopReason.select("id, shop_id, reason_ids").find_by(shop_id: shop_id)
        unless shop_reason_ids_data.nil?
            shop_reason_data = Reason.select("id, reason").where(id: JSON.parse(shop_reason_ids_data.reason_ids)).find_all
        else
            shop_reason_data = Reason.select("id, reason").find_all
        end
        # @shop_reason_ids_data = shop_reason_ids_data
        # @shop_reason_data = shop_reason_data
        @reason_list = Array.new
        i = 0;
        shop_reason_data.each do |shop_reason|
            @reason_list[i] = [shop_reason.reason, shop_reason.reason]
            i += 1;
        end
        # Save data to rule table
        conditions = Hash.new
        conditions = {"cond_field" => params[:cond_field], "cond_param" => params[:cond_param], "cond_value" => params[:cond_value]}
        # @conditions_json = conditions.to_json
        save_rule = Rule.create(shop_id: shop_id, name: params[:rule_name], priority: params[:rule_priority], conditions: conditions.to_json)
        if save_rule.valid?
            flash[:notice] = "Success! Rule has been successfully created."
            redirect_to '/rules'
        else
            @errors_messages = save_rule.errors[:name]
            render "create_rule"
        end
        # render "create_rule"
    end

    # update rule
    def update_rule
        @params = params
        current_shop_domain = ShopifyAPI::Shop.current.domain
        shop = Shop.find_by(shopify_domain: current_shop_domain)
        shop_id = shop.id
        @rule_priority_list = [['1', 1], ['2', 2], ['3', 3], ['4', 4], ['5', 5]];
        @cond_field_list = [['Order Value', 'OV'], ['Order Discount Value', 'ODV'], ['Order Discount Percent', 'ODP'], ['Order Country', 'OC'], ['Order Return Reason', 'ORR']];
        @cond_param_compare_list = [['Greater Than', 'GT'], ['Less Than', 'LT'], ['Greater Than or Equal to', 'GTET'], ['Less Than or Equal to', 'LTET'], ['Equal to', 'ET']];
        @cond_param_boolean_list = [['Is', 'IET'], ['Is Not', 'INET']];
        @selected_cond_filed = 'OV'
        # @country_list = [['United States', 'US'], ['United Kingdom', 'UK'], ['Australia', 'AU'], ['New Zealand', 'NZ'], ['India', 'IN']];
        country_data = Country.select("id, iso, nicename").find_all
        @country_list = Array.new
        i = 0;
        country_data.each do |country|
            @country_list[i] = [country.nicename, country.iso]
            i += 1;
        end
        # @country_list = country_list;
        @reason_list = [['Size - Too Small', 'Size - Too Small'], ['Size - Too Large', 'Size - Too Large'], ['Style', 'Style'], ['Color', 'Color'], ['Too Expensive', 'Too Expensive']];
        shop_reason_ids_data = ShopReason.select("id, shop_id, reason_ids").find_by(shop_id: shop_id)
        unless shop_reason_ids_data.nil?
            shop_reason_data = Reason.select("id, reason").where(id: JSON.parse(shop_reason_ids_data.reason_ids)).find_all
        else
            shop_reason_data = Reason.select("id, reason").find_all
        end
        # @shop_reason_ids_data = shop_reason_ids_data
        # @shop_reason_data = shop_reason_data
        @reason_list = Array.new
        i = 0;
        shop_reason_data.each do |shop_reason|
            @reason_list[i] = [shop_reason.reason, shop_reason.reason]
            i += 1;
        end
        @rule_data = Rule.find_by(id: params[:id])
    end

    # submit update rule
    def submit_update_rule
        @params = params
        current_shop_domain = ShopifyAPI::Shop.current.domain
        shop = Shop.find_by(shopify_domain: current_shop_domain)
        shop_id = shop.id
        @rule_priority_list = [['1', 1], ['2', 2], ['3', 3], ['4', 4], ['5', 5]];
        @cond_field_list = [['Order Value', 'OV'], ['Order Discount Value', 'ODV'], ['Order Discount Percent', 'ODP'], ['Order Country', 'OC'], ['Order Return Reason', 'ORR']];
        @cond_param_compare_list = [['Greater Than', 'GT'], ['Less Than', 'LT'], ['Greater Than or Equal to', 'GTET'], ['Less Than or Equal to', 'LTET'], ['Equal to', 'ET']];
        @cond_param_boolean_list = [['Is', 'IET'], ['Is Not', 'INET']];
        @selected_cond_filed = 'OV'
        # @country_list = [['United States', 'US'], ['United Kingdom', 'UK'], ['Australia', 'AU'], ['New Zealand', 'NZ'], ['India', 'IN']];
        country_data = Country.select("id, iso, nicename").find_all
        @country_list = Array.new
        i = 0;
        country_data.each do |country|
            @country_list[i] = [country.nicename, country.iso]
            i += 1;
        end
        # @country_list = country_list;
        @reason_list = [['Size - Too Small', 'Size - Too Small'], ['Size - Too Large', 'Size - Too Large'], ['Style', 'Style'], ['Color', 'Color'], ['Too Expensive', 'Too Expensive']];
        shop_reason_ids_data = ShopReason.select("id, shop_id, reason_ids").find_by(shop_id: shop_id)
        unless shop_reason_ids_data.nil?
            shop_reason_data = Reason.select("id, reason").where(id: JSON.parse(shop_reason_ids_data.reason_ids)).find_all
        else
            shop_reason_data = Reason.select("id, reason").find_all
        end
        # @shop_reason_ids_data = shop_reason_ids_data
        # @shop_reason_data = shop_reason_data
        @reason_list = Array.new
        i = 0;
        shop_reason_data.each do |shop_reason|
            @reason_list[i] = [shop_reason.reason, shop_reason.reason]
            i += 1;
        end
        # Save data to rule table
        conditions = Hash.new
        conditions = {"cond_field" => params[:cond_field], "cond_param" => params[:cond_param], "cond_value" => params[:cond_value]}
        # @conditions_json = conditions.to_json
        rule_data = Rule.find_by(id: params[:id])
        @rule_data = rule_data
        save_rule = rule_data
        save_rule.update(shop_id: shop_id, name: params[:rule_name], priority: params[:rule_priority], conditions: conditions.to_json)
        if save_rule.valid?
            flash[:notice] = "Success! Rule has been successfully updated."
            redirect_to '/rules'
        else
            @errors_messages = save_rule.errors[:name]
            render "update_rule"
        end
          
    end
 
    # remove rule data
    def remove_rule
        @parmas = params
        rule = Rule.find_by(id: params[:id]).destroy
        flash[:notice] = "Success! Rule has been successfully deleted."
        redirect_to '/rules'
    end

    # add options to rule
    def add_options_to_rule
        @parmas = params
    end

    # submit add option to rule page
    def submit_add_options_to_rule
        @parmas = params
        current_shop_domain = ShopifyAPI::Shop.current.domain
        shop = Shop.find_by(shopify_domain: current_shop_domain)
        shop_id = shop.id
        rule_id = params[:rule_id]
        if params[:return_shipping_fee].nil?
            return_shipping_fee = 0
        else
            return_shipping_fee = 1
        end
        if params[:return_window].nil?
            params[:return_window] = 0
        end
        rule_option = RuleOption.find_by(rule_id: rule_id)
        if rule_option.nil?
            save_rule_options = RuleOption.create(shop_id: shop_id, rule_id: rule_id, refund_method: params[:refund_method], return_window: params[:return_window],  return_shipping_fee: return_shipping_fee)
            flash[:notice] = "Success! Rule Option has been successfully created."
        else
            save_rule_options = RuleOption.find_by(rule_id: rule_id)
            save_rule_options.update(refund_method: params[:refund_method], return_window: params[:return_window],  return_shipping_fee: return_shipping_fee)
            flash[:notice] = "Success! Rule Option has been successfully updated."
        end
        redirect_to '/rules'
        # render "add_options_to_rule"
    end

    # update option to rule
    def update_options_to_rule
        @parmas = params
        @rule_option_data = RuleOption.find_by(id: params[:id])
    end

    # submit update option to rule
    def submit_update_options_to_rule
        @parmas = params
        if params[:return_shipping_fee].nil?
            return_shipping_fee = 0
        else
            return_shipping_fee = 1
        end
        if params[:return_window].nil?
            params[:return_window] = 0
        end
        @rule_option_data = RuleOption.find_by(id: params[:id])
        save_rule_options = RuleOption.find_by(id: params[:id])
        save_rule_options.update(refund_method: params[:refund_method], return_window: params[:return_window],  return_shipping_fee: return_shipping_fee)
        flash[:notice] = "Success! Rule Option has been successfully updated."
        redirect_to '/rules'
        # render "update_options_to_rule"
    end

    # remove rule option
    def remove_rule_option
        @parmas = params
        rule_option = RuleOption.find_by(id: params[:id]).destroy
        flash[:notice] = "Success! Rule Option has been successfully deleted."
        redirect_to '/rules'
    end
end
