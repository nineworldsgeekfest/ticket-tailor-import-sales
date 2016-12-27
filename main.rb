#!/usr/bin/env ruby
require 'mechanize'
require 'yaml'
# There isn't any separation between development and production at this stage
require 'pry'

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

# Navigate to the tickets page via a route that validates CSRF
page = page.links.find {|link|link.uri.to_s.include? 'buytickets.at'}.click
page = page.links.find {|link| link.uri.to_s.include? '/checkout/view-event/id/' + @event }.click

# Open a CSV file with upload data

# Enter ticket quantities into shopping cart
form = page.form
pp form
binding.pry

# Enter purchaser details into checkout form

# Enter transaction ID into conrirmation form and confirm allocation
