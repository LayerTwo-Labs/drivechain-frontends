#!/usr/bin/env bash

set -e

app_name=Launcher

echo "" > build-vars.env

# Export the app_name variable so it's available to the parent script
export app_name