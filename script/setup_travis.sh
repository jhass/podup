#!/bin/bash
echo "copy config/database.yml.example to config/database.yml"
cp config/database.yml.example config/database.yml

echo "copy config/settings.yml.example to config/settings.yml"
cp config/settings.yml.example config/settings.yml

echo "fetch geoip database"
./script/get_geoip.sh

echo "create test database"
mysql -e 'create database podup_test;' >/dev/null

echo "load database schema"
RAILS_ENV=test bundle exec rake db:schema:load

echo "generate secret token"
bundle exec rake generate:secret_token
