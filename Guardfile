# A sample Guardfile
# More info at https://github.com/guard/guard#readme
guard 'less', :all_on_start => true, :all_after_change => true, :output => 'public/stylesheets/compiled' do
  watch(%r{^app/stylesheets/(.+\.less)$})
end

guard :jammit do
  watch(%r{^public/javascripts/(.*)\.js$})
  watch(%r{^public/stylesheets/(.*)\.css$})
end

guard 'coffeescript', :input => 'app/javascripts', :output => 'public/javascripts/compiled'
