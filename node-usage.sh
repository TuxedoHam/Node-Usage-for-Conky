#!/bin/bash
## node-usage.sh
## Author:
## Dale Hopkins <me@dale.id.au> https://dale.id.au
## Created on 8th April 2010.
## Licensed under the GPL version 3.
##
## Get usage information from Internode's web page.
## requires: curl and gawk
##
## Refer to README for instructions and info.


## DO NOT EDIT THIS FILE UNLESS YOU KNOW WHAT YOUR DOING.

ver=0.0.6

if [ -n $1 ]; then
    echo "Using account: $1"
    conf_dir="$HOME/.config/internode/$1"
    HOME=$conf_dir
    netrc="$conf_dir/.netrc"
fi

cache_dir=$conf_dir/cache
tmp_dir=$conf_dir/tmp
log=$conf_dir/node-usage.log
url=https://customer-webtools-api.internode.on.net/api/v1.5/
curl="`which curl` -s -n -A \"Node\ Usage\ for\ Conky\ $ver\" -e http://dale.id.au/pub/node-usage/"

# Create and check for working directories
if [ ! -d $cache_dir ]; then 
	mkdir -p $cache_dir
fi

if [ ! -d $tmp_dir ]; then 
	mkdir -p $tmp_dir
fi

# Grab the details
if [ ! -f $netrc ]; then
	echo "Have you read the README.... ($netrc is missing)"
	exit 0
else
	$curl $url > $tmp_dir/api
fi

sleep 1

service=$(cat $tmp_dir/api |sed -n 2p|cut -d">" -f5|cut -d"<" -f1)

if [ ! $service ]; then
echo "`date +%b` `date +%e` `date +%T` : connect error unknown" >> $log
exit 0
else
$curl $url$service/usage > $tmp_dir/usage
fi

if [ ! $service ]; then
echo "`date +%b` `date +%e` `date +%T` : connect error unknown" >> $log
exit 0
else
$curl $url$service/history > $tmp_dir/history
fi

# Process the usage
rollover=$(cat $tmp_dir/usage |sed -n 2p|cut -d"=" -f5|cut -d'"' -f2)
quota=$(cat $tmp_dir/usage |sed -n 2p|cut -d"=" -f7|cut -d'"' -f2)
used=$(cat $tmp_dir/usage |sed -n 2p|cut -d">" -f6|cut -d"<" -f1)
today=$(cat $tmp_dir/history | grep  'traffic' | tr -d '\t' | sed 's/^<.*>\([^<].*\)<.*>$/\1/' | cut -d"<" -f1)

# Break up the values into their respective parts
echo "$used $quota $today" > $tmp_dir/node-text.txt
echo "$(cat $tmp_dir/node-text.txt | gawk 'BEGIN{OFMT = "%.2f"}{print $1/1000/1000}') MB" > $cache_dir/node-used.txt 
echo "$(cat $tmp_dir/node-text.txt | gawk '{print $2/1000/1000}') MB" > $cache_dir/node-quota.txt
echo "$(cat $tmp_dir/node-text.txt | gawk 'BEGIN{OFMT = "%.2f"}{print $3/1000/1000}') MB" > $cache_dir/node-today.txt

# Generate the percent used.
cat $tmp_dir/node-text.txt | gawk '{print $1/$2*100}' > $cache_dir/node-graph.txt
percent=$(cat $cache_dir/node-graph.txt)
echo $(printf %.0f $percent) > $cache_dir/node-percent.txt

# Generate the days left
today=$(date +%s)
rollunixdate=$(date +%s -d"$rollover 23:59:59")
diffunix=$(expr $rollunixdate - $today)
daysleft=$(expr $diffunix / 86400)

echo "$daysleft" > $cache_dir/node-rollover.txt

# Generate days in a month
unixdate=$(date -d"$rollover" +%s)
unixmonth=$(date -d"$rollover +1 month" +%s)
unixdaysmonth=$(expr $unixmonth - $unixdate)
daysmonth=$(expr $unixdaysmonth / 86400)
dayspast=$(expr $daysmonth - $daysleft)

# Generate quote left and average usage per day based on quota left
echo "(($quota/1000/1000)-($used/1000/1000))/$daysleft" |bc > $cache_dir/node-curdayavg.txt
echo "(($quota/1000/1000)-($used/1000/1000))" |bc > $cache_dir/node-left.txt
node_curdayavg=$(cat $cache_dir/node-curdayavg.txt)
node_remaining=$(cat $cache_dir/node-left.txt)
echo "$node_remaining MB ($node_curdayavg MB/day)" > $cache_dir/node-remaining.txt

exit
