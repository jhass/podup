#!/bin/bash
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz -O vendor/geoip_country.dat.gz
gunzip vendor/geoip_country.dat.gz
