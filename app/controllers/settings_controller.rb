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
        else
            save_product_exclusion_tag = ProductExclusionTag.find_by(shop_id: params[:shop_id])
            save_product_exclusion_tag.update(tag: params[:exclusion_tags])
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
        else
            save_shop_reasons = ShopReason.find_by(shop_id: shop_id)
            save_shop_reasons.update(reason_ids: selected_reasons)
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
        unless params[:reason].empty?
            # @display = "in unless #{@params[:reason]}"
            save_return_reason = Reason.create(reason: params[:reason])
        end
        render "add_new_return_reason"
    end

    # rules for return product
    def rules
        @params = params
    end

    # rules for return product
    def select_rule
        @params = params
    end
end
