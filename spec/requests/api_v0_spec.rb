require 'spec_helper'

describe "/api/v0" do
  include Rack::Test::Methods

  def app
    ApiV0
  end

  let(:message)             { "Dear congressman" }
  let(:name)                { "Obama" }
  let(:street1)             { "12045 Powerscourt Dr" }
  let(:street2)             { "Ste. 100" }
  let(:city)                { "St Louis" }
  let(:state)               { "MO" }
  let(:postalcode)          { "63131" }
  let(:card_number)           { "4242424242424242" }
  let(:generate_stripe_token) { Stripe.api_key = STRIPE_API_KEY; Stripe::Token.create(card: {number: card_number, exp_month: 4, exp_year: 2014, cvc: 314 }, currency: "usd") }
  let(:stripe_token)          { generate_stripe_token.id }
  let(:card)                  { stripe_token }

  let(:body)  { JSON.parse(last_response.body) }

  context "not requiring authorization" do
    describe "POST /postcards" do
      let(:params)    { {card: card, message: message, name: name, street1: street1, street2: street2, city: city, state: state, postalcode: postalcode} }

      before { post "/postcards.json", params, format: 'json' }

      context "valid card" do
        it { body['success'].should eq true }
        it { body['postcard']['id'].should eq 1 }
      end

      context "invalid card" do
        let(:card) { "invalidcard" }

        it { body['success'].should eq false }
      end

      context "missing message" do
        let(:message) { " " }

        it { body['success'].should eq false }
      end
    end

    describe "GET /senators" do
      before { get "/senators.json", {}, format: 'json' }

      it { body['success'].should eq true }
      it { body['senators'][0]['id'].should eq 6 }
      it { body['senators'][-1]['id'].should eq 4 }
    end

    describe "GET /legislators" do
      let(:params)  { {postalcode: 92504} }
      before        { get "/legislators.json", params, format: 'json'}

      it { body['success'].should eq true }
      it { body['legislators'].length.should eq 4 }
      it { body['legislators'][0]['name'].should eq 'Mark Takano' }
      it { body['legislators'][0]['name_and_party'].should eq 'Mark Takano (D)' }
      it { body['legislators'][0]['street1'].should eq '1507 Longworth House Office Building' }
    end
  end
end
