Requires a valid MS Genetics Intake Survey RedCAP token.

Requires httparty, pdfkit, and wkhtmltopdf gems be installed.

Requires mutt, mail, mailx, or other email service to be active on the server.

This script downloads intake survey data from the RedCAP api, parses out demographic data, and creates a pdf report of potential study subjects who have completed the survey within the prior week.

This process is intended to be run as a cron job. If running as a cron job, you must define your PATH at the top of your cron tab so that the system can execute ruby (the ruby binaries should be in a directory within the PATH). See https://www.ruby-forum.com/t/crontab-and-ruby-script-not-working/236452

Create a file named var.rb within the same directory as getandformatdata.rb. In var.rb, create the variable @my_token and set its value to your redcap api token.
