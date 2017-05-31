#!/usr/bin/env ruby
require 'mechanize'
require 'yaml'
require 'csv'
# There isn't any separation between development and production at this stage
require 'pry'

# Get name of CSV file from command line input, OR ask for it
if ARGV.empty?
  puts "Enter the name of the CSV import file, relative to the current directory:"
  @csv_file = gets.chomp
else
  @csv_file = ARGV[0]
end

# Get login details
ticket_tailor_login = YAML.load_file('.config/login.yml')
@username = ticket_tailor_login['username']
@password = ticket_tailor_login['password'].to_s
@event = ticket_tailor_login['event'].to_s

# Initialise the Mechanize agent
agent = Mechanize.new

# Load, fill in and submit the login page
page = agent.get 'https://www.tickettailor.com/login'
form = page.form
form['username'] = @username
form['password'] = @password
page = form.submit

# Open a CSV file with upload data
import_data = CSV.table @csv_file

# Navigate to the tickets page via a route that validates CSRF
page = page.links.find {|link|link.uri.to_s.include? 'buytickets.at'}.click
page = page.links.find {|link| link.uri.to_s.include? '/checkout/view-event/id/' + @event }.click

# Iterate through each row, adding the purchase to TT
import_data.each do |import_row|
  form = page.form

  # Add purchases to shopping cart
  import_row.select do |key, value|
    key.to_s.include? "quantity_"
  end.each do |product, quantity|
    form[product.to_s] = quantity
  end

  # Submit the shopping cart and load the checkout page
  page = form.submit
  if page.title != 'Checkout'
    puts 'Checkout page not loaded'
    pp page
    binding.pry
  end

  # Enter purchaser details into checkout form
  # NOTE that a discount form appears first if ticket choice includes discounts
  form = page.forms.last
  form['name'] = import_row[:name]
  form['email'] = import_row[:email]
  form['email_confirm'] = import_row[:email]
  # form['address_1'] =
  # form['address_2'] =
  form['address_3'] = import_row[:city]
  form['postcode'] = import_row[:postcode]

  # Submit the checkout form and load the payment page
  page = form.submit
  if page.title != 'Review'
    puts 'Review page not loaded'
    pp page
    binding.pry
  end

  # Free and paid orders have different processes
  if page.forms[1]
    # Enter transaction ID into confirmation form and submit allocation
    form = page.forms[1] # form_with would be better
    form['transactionId'] = import_row[:transactionid]
    page = form.submit
  else
    page = page.forms[0].submit
  end

  # Check successful submission
  if page.title != 'Order Complete'
    puts 'Order not successful for ' + import_row[:email]
    pp page
    binding.pry
  end

  # Post success info
  puts 'Added order for ' + import_row[:email]

  # Load up the shopping cart page ready for next time
  page = page.links.find {|link|link.uri.to_s.include? 'checkout/new-order'}.click

end
