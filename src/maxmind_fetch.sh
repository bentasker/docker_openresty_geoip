#!/bin/bash
#
# Maxmind database fetcher
#
# This is run as a discrete script to ensure secrets don't end up in the image history

# Load the license from secrets
. /run/secrets/maxmindsecret

# Fetch the DB
cd /usr/local/openresty/nginx/maxmind/
wget "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=${GEO_IP_LICENSE}&suffix=tar.gz" -O maxmind.tar.gz
tar xvzf maxmind.tar.gz
mv GeoLite2-Country*/* /usr/local/openresty/nginx/maxmind/
