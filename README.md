# ticket-tailor-import-sales
A simple import script for Ticket Tailor sales.

Uses Mechanize gem for HTTP communication.

## Login details
The login details are stored in `.config/login.yml` which is ignored by Git and thus not included in this repo. The keys are username, password, eventid, which you should set to your username and password and the number Ticket Tailor uses to represent the event before running.
