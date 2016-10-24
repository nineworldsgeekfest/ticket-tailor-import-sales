require 'capybara'
require 'capybara/poltergeist'
require 'phantomjs'

# Install and force set a path to Phantomjs
Phantomjs.path # => path to a phantom js executable suitable to your current platform. Will install before return when not installed yet.
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, :phantomjs => Phantomjs.path)
end

session = Capybara::Session.new(:poltergeist)

#Log into Ticket Tailor
session.visit "https://www.tickettailor.com/login"
