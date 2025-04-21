#!/usr/bin/env bash

set -e

app_name=BitWindow

echo "" > build-vars.env

# Export the app_name variable so it's available to the parent script
export app_name