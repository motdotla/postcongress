# encoding: utf-8
class Postcard
  include ActiveModel::Validations
  include ActiveModel::Dirty

  COUNTRY = 'UNITED STATES'

  attr_accessor :id, :stripe_charge_id, :message, :name, :street1, :street2, :city, :state, :postalcode, :sender_name, :sender_street1, :sender_street2, :sender_city, :sender_state, :sender_postalcode, :shipped, :ship_id, :print_id, :print_preview_url, :new_record
  alias :shipped? :shipped

  def initialize(attributes={})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  validates_presence_of :stripe_charge_id
  validates_presence_of :message
  validates_presence_of :name
  validates_presence_of :street1
  validates_presence_of :city
  validates_presence_of :state
  validates_presence_of :postalcode

  def message=(message)
    @message = message.to_s.strip
  end

  def new_record
    return true if @new_record.nil?
    @new_record
  end
  alias :new_record? :new_record

  def reference
    stripe_charge_id
  end

  def country
    COUNTRY
  end

  def test_mode
    !Sinatra::Application.production?
  end
  alias :test_mode? :test_mode

  def save
    return false if !valid?

    self.id = id || next_id
    REDIS.hmset(redis_key, 
      'stripe_charge_id', stripe_charge_id, 
      'message', message, 
      'name', name, 
      'street1', street1, 
      'street2', street2, 
      'city', city,
      'state', state,
      'postalcode', postalcode,
      'country', country,
      'sender_name', sender_name, 
      'sender_street1', sender_street1, 
      'sender_street2', sender_street2, 
      'sender_city', sender_city,
      'sender_state', sender_state,
      'sender_postalcode', sender_postalcode,
      'shipped', shipped,
      'ship_id', ship_id,
      'print_id', print_id
    )
    REDIS.sadd("postcards", redis_key)
    REDIS.hmset("postcards:stripe_charge_ids", stripe_charge_id, redis_key)

    Postcard.find(id)
  end

  def destroy
    REDIS.del(redis_key)
    REDIS.srem("postcards", redis_key)
    REDIS.hdel("postcards:stripe_charge_ids", stripe_charge_id)
    true
  end

  def create_shipping_order!
    return false if shipped?
    url = 'https://snapi.sincerely.com/shiplib/create'
    request = {
      :appkey => SHIP_API_KEY,
      :message => message,
      :testMode => test_mode,
      :frontPhotoId => FRONT_PHOTO_IDS[rand(FRONT_PHOTO_IDS.length)],
      :recipients => [{
        name:       name,
        street1:    street1,
        street2:    street2,
        city:       city,
        state:      state,
        postalcode: postalcode,
        country:    COUNTRY
      }].to_json,
      :sender => {
        name:         sender_name,
        email:        "postcongress@mailinator.com",
        street1:      sender_street1,
        street2:      sender_street2,
        city:         sender_city,
        state:        sender_state,
        postalcode:   sender_postalcode,
        country:      COUNTRY
      }.to_json
    }

    resp = RestClient.post(url,request, accept: :json)
    json = JSON.parse(resp)

    if !!json['success']
      self.ship_id  = json['id']
      self.print_id = json['sent_to'][0]["printId"]
      self.print_preview_url = json['sent_to'][0]['previewUrl']
      self.shipped  = true
      self.save
    else
      puts "===================================="
      puts "POSTCARD FAIL"
      puts json
      puts "===================================="
      false
    end
  end

  def self.count
    REDIS.get("postcards:count").to_i
  end

  def self.real_count
    REDIS.smembers("postcards").length
  end

  def self.find(id)
    raw = REDIS.hgetall("postcard:#{id}")

    return nil if !raw || raw.blank?

    postcard                    = Postcard.new
    postcard.new_record         = false
    postcard.id                 = id.to_i
    postcard.stripe_charge_id   = raw['stripe_charge_id']
    postcard.message            = raw['message']
    postcard.name               = raw['name']
    postcard.street1            = raw['street1']
    postcard.street2            = raw['street2']
    postcard.city               = raw['city']
    postcard.state              = raw['state']
    postcard.postalcode         = raw['postalcode']
    postcard.sender_name        = raw['sender_name']
    postcard.sender_street1     = raw['sender_street1']
    postcard.sender_street2     = raw['sender_street2']
    postcard.sender_city        = raw['sender_city']
    postcard.sender_state       = raw['sender_state']
    postcard.sender_postalcode  = raw['sender_postalcode']
    postcard.shipped            = (raw['shipped'] == 'true')
    postcard.ship_id            = raw['ship_id']
    postcard.print_id           = raw['print_id']
    postcard.print_preview_url  = raw['print_preview_url']

    postcard
  end

  def self.find_by_stripe_charge_id(stripe_charge_id)
    raw = REDIS.hget("postcards:stripe_charge_ids", stripe_charge_id)
    id = key_to_id(raw)
    find(id)
  end

  def self.all
    raw = REDIS.hvals("postcards:stripe_charge_ids")
    raw.map do |key|
      id = Postcard.key_to_id(key)
      Postcard.find(id)
    end
  end

  private

  def redis_key
    "postcard:#{id}"
  end

  def next_id
    REDIS.incr("postcards:count")
  end

  def self.key_to_id(key)
    key.to_s.gsub("postcard:", "")
  end
end