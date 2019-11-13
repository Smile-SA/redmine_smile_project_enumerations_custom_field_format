#!/bin/bash

cd ../..

RAILS_ENV=test rails redmine:plugins:test NAME=redmine_smile_project_enumerations_custom_field_format

