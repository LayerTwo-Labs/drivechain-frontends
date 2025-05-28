#!/usr/bin/env bash

set -e

echo "" > build-vars.env

app_name=BitAssets
# Export the app_name variable so it's available to the parent script
export app_name