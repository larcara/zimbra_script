require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'highline', require: false
  gem 'betterlorem', require: false
  gem 'chunky_png', require: false
  gem 'mail', require: false
  gem 'dotenv', require: false

end

require 'highline'
require 'betterlorem'
require 'chunky_png'
require 'mail'
require 'dotenv'
Dotenv.load("conf.env")
# EX Env file:
#RECIPIENT=user@zimbra.local
#MAIL_SIZE=40
#HOW_MANY=5
#IMG_SIZE=100
#MTA=mail.zimbra.local

VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
Random.new_seed


cli = HighLine.new


mta = cli.ask("mta address?") { |q| q.default = ENV["MTA"]}
puts "You have answered: #{mta}"



recipient = cli.ask("recipients?") { |q| q.default = ENV["RECIPIENT"]}
puts "You have answered: #{recipient}"

mail_size = cli.ask("Size in K?" , Integer) { |q|  q.default = ENV["MAIL_SIZE"].to_i}
puts "You have answered: #{mail_size}"

how_many = cli.ask("how_many? ", Integer) { |q| q.default = ENV["HOW_MANY"].to_i}
puts "You have answered: #{how_many}"

include_images = cli.ask("Include images? (y/n)") { |q| q.validate = /[yn]/}
puts "You have answered: #{include_images}"

if include_images == "y"
  image_size = cli.ask("Image Size X*X? 1 .. 100", Integer) { |q|  q.default = ENV["IMG_SIZE"].to_i}
  puts "You have answered: #{image_size}"

end

mail_body =  BetterLorem.c(mail_size, false, true )
Mail.defaults do
  delivery_method :smtp, address: mta, port: 25
end

how_many.times do
  mail = Mail.new do
    from    'test@local.local'
    to      recipient
    subject "This is a test email - #{Time.now}"
  end
  mail.body=mail_body
  if include_images=="y"
    png = ChunkyPNG::Image.new(image_size, image_size, ChunkyPNG::Color::TRANSPARENT)
    image_size.times do
      png[rand(image_size),rand(image_size)] = ChunkyPNG::Color('black @ 0.5')
    end
    mail.attachments['image.png'] = { :mime_type => 'image/png', :content => png.to_s }
  end
  mail.deliver!
  print "."
end
