# frozen_string_literal: true

class HomeController < AuthenticatedController

  # Index action
  def index
    @params = params
    @products = ShopifyAPI::Product.find(:all, params: { limit: 10 })
    @webhooks = ShopifyAPI::Webhook.find(:all)
  end

  # Create order webhook
  def create_order_webhook
    new_webhook = ShopifyAPI::Webhook.new({:topic => "orders/create", :address => "https://test.omnirps.com/webhook/create_order_webhook", :format => "json"})
    new_webhook.save
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
  end
end
