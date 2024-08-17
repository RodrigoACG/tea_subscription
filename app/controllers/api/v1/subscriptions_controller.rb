class Api::V1::SubscriptionsController < ApplicationController
  
  def create
    customer = find_customer_by_email(params[:customer_email])
    subscription = customer.subscriptions.new(sub_params)

    if subscription.save
     render json: SubscriptionSerializer.new(subscription), status: :created
    else
     render json: subscription.errors, status: :unauthorized
    end
  end

  def update 
    subs = Subscription.find(params[:subscription_id])

    if subs.update(sub_params)
      render json: SubscriptionSerializer.new(subs), status: :ok
    else
      render json: subs.errors, status: :unprocessable_entity
    end
    # require 'pry'; binding.pry
  end

  def index 
    customer = Customer.find(params[:customer_id])
    render json: SubscriptionSerializer.new(customer.subscriptions)

  end

  private 

  def sub_params
    params.permit(:title, :price, :frequency, :status)
  end
end