#!/bin/bash
echo "copy config/database.yml.example to config/database.yml"
cp config/database.yml.example config/database.yml

echo "create test database"
mysql -e 'create database podup_test;' >/dev/null
