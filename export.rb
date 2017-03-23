#!/usr/bin/env ruby
require 'mechanize'
require 'yaml'
require 'csv'
require 'google_drive'
# There isn't any separation between development and production at this stage
require 'pry'

# Get name of CSV file from command line input, OR ask for it
# if ARGV.empty?
#   puts "Enter the name of the CSV export file, relative to the current directory:"
#   @csv_file = gets.chomp
# else
#   @csv_file = ARGV[0]
# end

# Get login details
ticket_tailor_login = YAML.load_file('.config/login.yml')
@username = ticket_tailor_login['username']
@password = ticket_tailor_login['password'].to_s
@event = ticket_tailor_login['event'].to_s
@sheet_key = ticket_tailor_login['sheet_key'].to_s

# Open a Google Drive session
session = GoogleDrive::Session.from_service_account_key(".config/google_config.json")

# Open the Google Sheet
sheet = session.spreadsheet_by_key(@sheet_key).worksheets[0]

sheet[2, 1] = "foo"
sheet.save

binding.pry
exit
# Initialise the Mechanize agent
agent = Mechanize.new

# Load, fill in and submit the login page
page = agent.get 'https://www.tickettailor.com/login'
form = page.form
form['username'] = @username
form['password'] = @password
page = form.submit

# Navigate to event page https://www.tickettailor.com/event/view/id/@event
# Navigate to order mgmt https://www.tickettailor.com/event/view-orders/id/@event
# Navigate to order export https://www.tickettailor.com/event/export-orders/id/@event
page = agent.get "https://www.tickettailor.com/event/export-orders/id/#{@event}"
# Select download and filter fields if appropriate
# Click export button #submit
page = page.form.submit
# Click long link beginning https://www.tickettailor.com/event/export-orders-download/id/@event/
# and labelled Click here to download your orders report
file_export = page.link_with(:text => "Click here to download your orders report").click
# This opens a page which becomes the CSV download
csv_export = CSV.parse(file_export.body)
# Move to pry for further manipulation. Still to write the export code, targeting GSheets
binding.pry
