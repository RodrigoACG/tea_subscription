require 'rails_helper'

RSpec.describe 'subscription' do
  

  describe '#us 1' do
  before(:each) do
    @c1 = Customer.create!( first_name: "ab", last_name: "cd", email: "abcd@gmail.com", address: "123 road")
    @t1 = Tea.create!(title: "Gin",description: "get better",temperature: "208°F",brew_time: "5 - 10 minutes")
    @headers = { "Content-Type": "application/json", "Accept": "application/json" }
  end
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


  describe 'us 2' do
    before :each do 
      @customer1 = Customer.create!(first_name: "Bob",last_name: "ghjskm", email: "ajshbdbjt@gmail.com",address: "something, road")
      @tea1 = Tea.create!(title: "Ginseng",description: "Ginseng has been used for improving overall health.", temperature: "208°F", brew_time: "5 - 10 minutes")
      @subscription1 = @customer1.subscriptions.create!(title: "#{@tea1.title}",price: 6.00,frequency: "1 week")
      @headers = { "Content-Type": "application/json","Accept": "application/json" }
    end

    describe 'happy path' do
      it 'updates a subscription status to cancelled' do
        params = {
          subscription_id: @subscription1.id,
          status: 1
        }

        

        patch api_v1_customer_subscription_path(@customer1, @subscription1), headers: @headers, params: JSON.generate(params)

        result = JSON.parse(response.body, symbolize_names: true)
        expect(result).to be_a(Hash)
        
        expect(response.status).to eq(200)
        expect(response).to be_successful

        expect(result[:data][:attributes][:status]).to eq("active")

        #Changed status to active because its defaulted to cancelled

      end
    end

    describe 'Sad path' do
      it 'does not update status when subscription id does not match' do
        params = {
          subscription_id: 123456,
          status: 1
        }

        patch api_v1_customer_subscription_path(@customer1, @subscription1), headers: @headers, params: JSON.generate(params)

        result = JSON.parse(response.body, symbolize_names: true)
        expect(result).to be_a(Hash)
        
        expect(response.status).to eq(401)
        expect(response).to_not be_successful
      
        expect(result).to have_key(:error)
        expect(result[:error]).to eq("Sorry, your credentials are bad!")
      end
    end

    describe 'Sad path' do
      it 'does not update status when subscription id does not match' do
        params = {
          subscription_id: 123456,
          status: 1
        }
  
        patch api_v1_customer_subscription_path(@customer1, 456765), headers: @headers, params: JSON.generate(params)
  
        result = JSON.parse(response.body, symbolize_names: true)
        expect(result).to be_a(Hash)
        
        expect(response.status).to eq(401)
        expect(response).to_not be_successful
      
        expect(result).to have_key(:error)
        expect(result[:error]).to eq("Sorry, your credentials are bad!")
      end
    end
  end

  describe 'subs Index' do
    before :each do 
      @customer1 = Customer.create!(first_name: "tom",last_name: "has", email: "sddest@gmail.com",address: "11234 st")
      @customer2 = Customer.create!(first_name: "bob",last_name: "asdh", email: "nice@gmail.com",address: "123 rd")
      @tea1 = Tea.create!(title: "Ginseng",description: "It has also been used to strengthen the immune system and help fight off stress and disease.",temperature: "208°F",brew_time: "5 - 10 minutes")
      @subscription1 = @customer1.subscriptions.create!(title: "#{@tea1.title}",price: 6.00,frequency: "1 week", status: 1 )
      @subscription2 = @customer1.subscriptions.create!(title: "subscription2 ",price: 9.00,frequency: "15 weeks" )
      @subscription2 = @customer2.subscriptions.create!(title: "subscription3 ",price: 10.00,frequency: "4 weeks" )

    end

    describe 'Happy path ' do
      it 'shows customer subscriptions' do
        
        get api_v1_customer_subscriptions_path(@customer1)

        result = JSON.parse(response.body, symbolize_names: true)[:data]

        require 'pry'; binding.pry

        expect(result.first[:id]).to be_a(String)
        expect(result.first[:type]).to be_a(String)
        expect(result.first[:attributes][:title]).to be_a(String)
        expect(result.first[:attributes][:price]).to be_a(String)
        expect(result.first[:attributes][:frequency]).to be_a(String)
        expect(result.first[:attributes][:status]).to be_a(String)
         
        expect(result.last[:type]).to eq("subscription")
        expect(result.last[:attributes][:title]).to eq("subscription2 ")
        expect(result.last[:attributes][:price]).to eq("9.0")
        expect(result.last[:attributes][:frequency]).to eq("15 weeks")
        expect(result.last[:attributes][:status]).to eq("cancelled")
         
      end
    end

    describe 'Sad path' do
      it 'errors when ID does not match' do
        get "/api/v1/customers/5422345678987654/subscriptions"
        
        result = JSON.parse(response.body, symbolize_names: true)
        
        expect(response.status).to eq(401)
        expect(response).to_not be_successful

        expect(result).to have_key(:error)
        expect(result[:error]).to eq("Sorry, your credentials are bad!")
      end
    end
  end

end
    

  




