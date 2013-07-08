class ApiV0 < Application
  layout false

  post "/postcards.?:format?" do
    begin
      @postcard = Postcard.new
      @postcard.stripe_charge_id = "tmp_holder"
      @postcard.message = params[:message]
      @postcard.name    = params[:name]
      @postcard.street1 = params[:street1]
      @postcard.street2 = params[:street2]
      @postcard.city    = params[:city]
      @postcard.state   = params[:state]
      @postcard.postalcode      = params[:postalcode]
      @postcard.sender_name     = params[:sender_name]
      @postcard.sender_street1  = params[:sender_street1]
      @postcard.sender_street2  = params[:sender_street2]
      @postcard.sender_city     = params[:sender_city]
      @postcard.sender_state    = params[:sender_state]
      @postcard.sender_postalcode = params[:sender_postalcode]

      if @postcard.valid?
        @charge = Stripe::Charge.create(
          amount:       AMOUNT_IN_CENTS,
          currency:     CURRENCY,
          card:         params[:card],
          description:  "postcongress charge"
        )
        @postcard.stripe_charge_id = @charge.id
        @postcard.save
        jsonify :"/api_v0/postcards/create"
      else
        @message = @postcard.errors.full_messages.to_sentence
        jsonify :"/api_v0/error"
      end
    rescue Exception => e
      @message = e.message

      jsonify :"/api_v0/error"
    end
  end

  get "/senators.?:format?" do
    @senators = Senator.all
    jsonify :"/api_v0/senators/index"
  end

  get "/legislators.?:format?" do
    @legislators = Sunlight::Legislator.all_in_zipcode(params[:postalcode])
    jsonify :"/api_v0/legislators/index"
  end
end
