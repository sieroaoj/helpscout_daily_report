# Helpscout Daily Summary Mail Script

This is a ruby script to send a daily summary of the tickets to your support team.

The script uses the helpscout api to get the info and mailgun to send the email to your support team and boss 

## Usage

1. Follow the instructions at [Help Scout's Developers site](http://developer.helpscout.net/) to generate an API key.

2. Assign the api key in the variable

HELPSCOUT_API_KEY = ""

3. In line 99 of the funcition send_team_mail_message set your mailgun apikey

4. test the script 

5. set it in a cronb job

38 21 * * 1-5 /bin/bash -l -c 'cd /Users/path_to_script/help_scout_reports/ && ruby daily_helpscout_mail_report.rb'



