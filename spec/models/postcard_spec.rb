# encoding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe Postcard do
  let(:stripe_charge_id)    { "12345" }
  let(:message)             { "Dear congressman" }
  let(:name)                { "Obama" }
  let(:street1)             { "12045 Powerscourt Dr" }
  let(:street2)             { "Ste. 100" }
  let(:city)                { "St Louis" }
  let(:state)               { "MO" }
  let(:postalcode)          { "63131" }

  let(:postcard) do
    Postcard.new(
      stripe_charge_id: stripe_charge_id, 
      message: message, 
      name: name,
      street1: street1,
      street2: street2,
      city: city,
      state: state,
      postalcode: postalcode
    ) 
  end

  it { postcard.should be_valid }
  it { postcard.stripe_charge_id.should eq stripe_charge_id }
  it { postcard.message.should eq message }
  it { postcard.should be_new_record }
  it { postcard.reference.should eq stripe_charge_id }
  it { postcard.should be_test_mode }
  it { postcard.should_not be_shipped }

  context "missing stripe_charge_id" do
    before { postcard.stripe_charge_id = " " }

    it { postcard.should_not be_valid }
  end

  context "missing message" do
    before { postcard.message = " " }

    it { postcard.should_not be_valid }
  end

  context "sinatra application is production" do
    before do
      Sinatra::Application.stub(:production?).and_return(true)
    end

    it { postcard.should_not be_test_mode }
  end

  context "missing name" do
    before { postcard.name = " " }

    it { postcard.should_not be_valid }
  end

  context "missing street1" do
    before { postcard.street1 = " " }

    it { postcard.should_not be_valid }
  end

  context "missing city" do
    before { postcard.city = " " }

    it { postcard.should_not be_valid }
  end

  context "missing state" do
    before { postcard.state = " " }

    it { postcard.should_not be_valid }
  end

  context "missing postalcode" do
    before { postcard.postalcode = " " }

    it { postcard.should_not be_valid }
  end

  describe "#save" do
    before { postcard.save }

    context "default" do
      it { postcard.id.should_not be_blank }
      it { postcard.stripe_charge_id.should eq stripe_charge_id }
      it { postcard.message.should eq message }
      it { postcard.name.should eq name }
      it { postcard.street1.should eq street1 }
      it { postcard.street2.should eq street2 }
      it { postcard.city.should eq city }
      it { postcard.state.should eq state }
      it { postcard.postalcode.should eq postalcode }
      it { postcard.country.should eq Postcard::COUNTRY }
    end

    describe "queue to Sincerely ship library" do
      before { postcard.create_shipping_order! }

      it { postcard.should be_shipped }
      it { postcard.ship_id.should_not be_blank }
      it { postcard.print_id.should_not be_blank }
      it { postcard.print_preview_url.should_not be_blank }
    end

    describe "destroy" do
      before { postcard.destroy }

      it { Postcard.count.should eq 1 }
      it { Postcard.real_count.should eq 0 }
      it { Postcard.all.count.should eq 0 }
    end
  end

  describe ".find" do
    let(:id)        { postcard.id }
    let(:result)    { Postcard.find(id) }

    before { postcard.save }

    it { result.id.should eq postcard.id }
    it { result.should_not be_new_record }

    context "incorrect id" do
      let(:id) { "INCORRECTID!" }

      it { result.should be_nil }
    end
  end

  describe ".find_by_stripe_charge_id" do
    let(:original_stripe_charge_id)  { postcard.stripe_charge_id }
    let(:result)                     { Postcard.find_by_stripe_charge_id(original_stripe_charge_id) }

    before { postcard.save }

    it { result.id.should eq postcard.id }
    it { result.should_not be_new_record }

    context "incorrect stripe charge id" do
      let(:original_stripe_charge_id) { "INCORRECTID" }

      it { result.should be_nil }
    end
  end
end