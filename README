Author - Dale Hopkins <me@dale.id.au> http://dale.id.au
Licensed under the GPL version 3.

Prerequisites:

You need the following software installed for this script to work:
Curl - http://curl.haxx.se/
Gawk - http://www.gnu.org/software/gawk/
These packages should be available in you distribution's repository.

And of course Conky and an active Internode account.

Configure:

Make sure the script is executable:

$ `chmod 755 node-usage.sh`

Add the following line to `~/.netrc` remember to change `'myself'(username)` and `'secret'(password)`

machine customer-webtools-api.internode.on.net login myself password secret

Example of doing it via terminal:

$ `echo "machine customer-webtools-api.internode.on.net login myself password secret" >> ~/.netrc`

now to be safe do:

$ `chmod 600 ~/.netrc`

This is to make sure that the file is only readable by your account.

To get the script to update for example every 30 minutes do the following to cron:

$ `crontab -e`

and now add:

`*/30 * * * * ~/programs/scripts/node-usage.sh`

And it best not to have it updating anything less than 30 minutes.

Usage:

Here is the snippet of the code for the ~/.conkyrc file:
```
${color #5b6dad}Internode Usage: ${hr 1}
 ${color #7f8ed3}${execi 900 cat ~/.config/internode/cache/node-percent.txt}% ${execibar 900 cat ~/.config/internode/cache/node-graph.txt}
 ${color #5b6dad}Used: ${color #7f8ed3}${execi 900 cat ~/.config/internode/cache/node-used.txt}   ${color #5b6dad}Quota: ${color #7f8ed3}${execi 900 cat ~/.config/internode/cache/node-quota.txt}${alignr}${color #5b6dad}Days Left: ${color #7f8ed3}${execi 900 cat ~/.config/internode/cache/node-rollover.txt}
 ${color #5b6dad}Today: ${color #7f8ed3}${execi 900 cat ~/.config/internode/cache/node-today.txt}${alignr}${color #5b6dad}Remaining: ${color #7f8ed3}${execi 900 cat ~/.config/internode/cache/node-remaining.txt}
```

FAQ

What is Conky?
Conky is a free, light-weight system monitor for X, that displays any information on your desktop.

Where can I run the 'node-usage.sh' script?
In theory anywhere you like under your home directory

Where does Node Usage for Conky store its files?
You'll find them in your home directory under .config/internode/

What are all theses files in ~/.config/internode/cache/ directory?
These files are used to store the data that can be used in Conky.

Here is a break down of the files and what they used for:
node-curdayavg.txt - The average you can use for the day
node-graph.txt - percentage for producing the graph
node-left.txt - Data you have left for the month
node-percent.txt - percentage of data used
node-quota.txt - Monthly data quota
node-remaining.txt - Usage left for the month + day average
node-rollover.txt - The date your account rolls over
node-today.txt - Todays data used
node-used.txt - Overall data used for the month

How do monitor multiple accounts?
create an account directory in ~/.config/internode and create a ~/.config/internode/account/.netrc file.
Then execute the script like this node-usage.sh account
