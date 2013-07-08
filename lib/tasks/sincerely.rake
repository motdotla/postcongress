namespace :sincerely do
  desc "Ship any unshipped postcards"
  task :ship do
    @postcards = Postcard.all
    @postcards.map(&:create_shipping_order!)
  end
end
