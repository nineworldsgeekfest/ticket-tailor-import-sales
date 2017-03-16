# ticket-tailor-import-sales
Simple command line import scripts for Ticket Tailor sales.

Uses Mechanize gem for HTTP communication.

## Usage
### Login details
The login details are stored in `.config/login.yml` which is ignored by Git and thus not included in this repo. The keys are username, password, eventid, which you should set to your username and password and the number Ticket Tailor uses to represent the event.

### Importing tickets to Ticket Tailor
Create a CSV import file, with the following headings:
* name
* email
* city
* postcode
* transactionid for some unique identifier for each sale
* A quantity_[something] column for each ticket type you're importing. You can get the id of each ticket type by inspecting the site HTML.

Each subsequent row in the CSV contains details of one purchase to be imported, and can consist of any quantity of each of the defined ticket types. The mandatory fields are the same as on the Ticket Tailor website. Note that if you've got full address details as mandatory information for your event, or some other custom field, the import may fail. For the obvious reason that the information won't be provided.

After setting up the login details and the CSV, use `ruby import.rb name-of-the-CSV-import-file` to import the tickets into your event. If an import hits issues, they will _usually_ be trapped and you'll be thrown into a REPL (a Ruby command line called from within the program's execution) to see what's going on. To retry an import that partially failed, remove the rows that have already been imported, fix any errors in the data, and use the new CSV as the import source. Each imported ticket will use the import date as the purchase date, which can complicate later sales analysis. There isn't a way to fix this at present, unfortunately.

### Exporting tickets from Ticket Tailor to Google Sheets
Google Sheets is used as it can be accessed online on a regular basis. However, it does require setup of tokens and authentication.

## Development notes

- [x] Use Mechanize gem to log in to Ticket Tailor
- [x] Read an import CSV file into memory
- [x] Navigate to the chosen event
- [x] Fill in and submit page 1 - purchase selection
- [x] Fill in and submit page 2 - purchaser details
- [x] Fill in and submit page 3 - transaction ID
- [x] Test with dummy data, and add trapping of incorrect submissions
- [x] Test with a large scale live import
- [ ] Log into Google Sheets and create / access a sheet
- [ ] Select the export options
- [ ] Export the CSV file download link to memory
- [ ] Add new sales to the Google Sheet
- [ ] Create regular running code, or set a cron job to run the script
