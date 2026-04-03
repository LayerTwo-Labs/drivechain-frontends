#!/bin/bash
cd "$(dirname "$0")"
go test -v -tags integration -timeout 30s ./wallet/ -run "TestWalletIntegration/Phase1" > /tmp/orch_test_full.txt 2>&1
echo "EXIT: $?" >> /tmp/orch_test_full.txt
