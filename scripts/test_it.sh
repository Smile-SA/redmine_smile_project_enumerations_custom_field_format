#!/bin/bash

cd ../..

#RAILS_ENV=test rake test TEST=plugins/redmine_smile_project_enumerations_custom_field_format/test/functional/issues_controller_test.rb TESTOPTS="-n /test_post_create/"

RAILS_ENV=test rails redmine:plugins:test NAME=redmine_smile_project_enumerations_custom_field_format

