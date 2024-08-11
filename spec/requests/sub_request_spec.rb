require 'rails_helper'

RSpec.describe 'subscription' do
  before(:each) do
    @c1 = Customer.create!( first_name: "ab", last_name: "cd", email: "abcd@gmail.com", address: "123 road")
    @t1 = Tea.create!(title: "Gin",description: "get better",temperature: "208°F",brew_time: "5 - 10 minutes")
    @headers = { "Content-Type": "application/json", "Accept": "application/json" }
  end

  describe '#us 1' do
    it 'creates a subscription for customer and tea' do
      params = {
        customer_email: "#{@c1.email}",
        title: "#{@t1.title}",
        price: 9.00,
        status: 1 ,
        frequency: "1 week",
      }
      post api_v1_customer_subscriptions_path(@c1), headers: @headers, params: JSON.generate(params)

      json = JSON.parse(response.body, symbolize_names: true)

      # require 'pry'; binding.pry

      expect(response).to be_successful
      expect(response.status).to eq(201)

      expect(json).to have_key(:data)
      data = json[:data]

      expect(data).to have_key(:id)
      expect(data[:id]).to be_a(String)
      expect(data[:id]).to eq("#{data[:id]}")

      expect(data).to have_key(:type)
      expect(data[:type]).to eq("subscription")
      expect(data[:type]).to be_a(String)

      expect(data).to have_key(:attributes)
      expect(data[:attributes]).to be_a(Hash)

      attributes = data[:attributes]

      expect(attributes).to have_key(:title)
      expect(attributes[:title]).to be_a(String)
      expect(attributes[:title]).to eq("Gin")

      expect(attributes).to have_key(:price)
      expect(attributes[:price]).to be_a(String)
      expect(attributes[:price]).to eq("9.0")

      expect(attributes).to have_key(:frequency)
      expect(attributes[:frequency]).to be_a(String)
      expect(attributes[:frequency]).to eq("1 week")


      expect(attributes).to have_key(:status)
      expect(attributes[:status]).to be_a(String)
      expect(attributes[:status]).to eq("active")

    end

    it 'sad path' do
      params = {
        customer_email: "#{@c1.email}",
        price: 9.00,
        status: 1 ,
      }

      post api_v1_customer_subscriptions_path(@c1), headers: @headers, params: JSON.generate(params)

      post api_v1_customer_subscriptions_path(@c1), headers: @headers, params: JSON.generate(params)

      result = JSON.parse(response.body, symbolize_names: true)
      
      # require 'pry'; binding.pry
      expect(response.status).to eq(401)
      expect(response).to_not be_successful

      expect(result).to be_a(Hash)
      expect(result[:title].first).to eq("can't be blank")
      expect(result[:frequency].first).to eq("can't be blank")

    end

    it 'sad path2' do
      params = {
        customer_email: "123456@gmail.com",
        price: 9.00,
        status: 1 ,
      }

      post api_v1_customer_subscriptions_path(@c1), headers: @headers, params: JSON.generate(params)

      post api_v1_customer_subscriptions_path(@c1), headers: @headers, params: JSON.generate(params)

      result = JSON.parse(response.body, symbolize_names: true)
      
      # require 'pry'; binding.pry
      expect(response.status).to eq(401)
      expect(response).to_not be_successful
      # require 'pry'; binding.pry

      expect(result).to be_a(Hash)
      expect(result[:error]).to be_a(String)
      expect(result[:error]).to eq("Sorry, your credentials are bad!")

    end

  end
end