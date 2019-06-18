# frozen_string_literal: true

class HomeController < AuthenticatedController
  def index
    @products = ShopifyAPI::Product.find(:all, params: { limit: 10 })
    @webhooks = ShopifyAPI::Webhook.find(:all)
  end
  def create_order_webhook
    new_webhook = ShopifyAPI::Webhook.new({:topic => "orders/create", :address => "https://orwhitelabel.omniparcelreturns.com/webhook/create_order_webhook", :format => "json"})
    new_webhook.save
    # @webhooks = ShopifyAPI::Webhook.find(:all)
    redirect_to 'home/index'
  end
  def remove_webhook
    # ShopifyAPI::Webhook.delete(440764661817 )
    redirect_to 'home/index'
  end
  def test
    @user = 'Sohail'
    my_hash = JSON.parse('{"hello": "goodbye"}')
    @my_hash = JSON.generate(my_hash)
  end
end
