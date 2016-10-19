#!/usr/bin/env bash

bundle exec rake db:create

sleep 1
bundle exec napa generate model User
sleep 1
bundle exec napa generate model Business token:string check_in_timeout:integer
sleep 1
bundle exec napa generate model CheckIn
sleep 1
bundle exec napa generate migration AddUserRefToCheckIns user:references
sleep 1
bundle exec napa generate migration AddBusinessRefToCheckIns business:references

sleep 1
bundle exec rake db:migrate

bundle exec napa generate api users
bundle exec napa generate api businesses
bundle exec napa generate api check_ins
