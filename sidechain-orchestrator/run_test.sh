#!/bin/bash
cd "$(dirname "$0")"
go test -v -tags integration -timeout 30s ./wallet/ -run "TestWalletIntegration/Phase1" 2>&1 | grep -E "orchd|serving|error|bind|ready|frame|started" > /tmp/orch_test_output.txt 2>&1
