#!/bin/bash

set -u

PASSED_TESTS=0
FAILED_TESTS=0

run_cli() {
    IMAGE_NAME="${IMAGE_NAME:-assignment3}"
    LAST_OUTPUT=$(docker run --rm "$IMAGE_NAME" "$@" 2>&1)
    LAST_EXIT_CODE=$?
}
assert_cli() {
    local test_name=$1
    local expected_exit_code=$2
    local expected_text=$3
    shift 3

    run_cli "$@"
    if [ "$LAST_EXIT_CODE" -eq "$expected_exit_code" ] && [[ "$LAST_OUTPUT" == *"$expected_text"* ]]; then
        printf ' \033[0;32m[PASS]\033[0m %s\n' "$test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        printf ' \033[0;31m[FAIL]\033[0m %s\n' "$test_name"
        printf '    Expected exit code: %s, text: %s\n' "$expected_exit_code" "$expected_text"
        printf '    Actual exit code: %s\n    Actual output: %s\n' "$LAST_EXIT_CODE" "$LAST_OUTPUT"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

echo "========================================="
# echo "Starting Docker Image Validation Tests"
# echo "Target Image: $IMAGE_NAME"
echo "========================================="

assert_cli "Help displays usage" 0 "Usage:" help
assert_cli "System-info displays the hostname" 0 "Hostname:" system-info
assert_cli "Invalid command returns exit code 2" 2 "Invalid option" invalid_command
assert_cli "Check-host without a host returns exit code 2" 2 "host cannot be empty" check-host
assert_cli "Check-host with a valid host checks connectivity" 0 "Connectivity check" check-host localhost
assert_cli "Check-port without a port returns exit code 2" 2 "port must be a number from 1 to 65535" check-port localhost
assert_cli "Check-port rejects a non-numeric port" 2 "port must be a number from 1 to 65535" check-port localhost abc
assert_cli "Check-port rejects port zero" 2 "port must be a number from 1 to 65535" check-port localhost 0
assert_cli "Check-port rejects a port above 65535" 2 "port must be a number from 1 to 65535" check-port localhost 65536

echo ""
echo "========================================="
echo "Test Summary"
echo "========================================="
echo "Passed Tests: $PASSED_TESTS"
echo "Failed Tests: $FAILED_TESTS"
echo "Total Tests: $((PASSED_TESTS + FAILED_TESTS))"
echo "========================================="

if [ "$FAILED_TESTS" -eq 0 ]; then
    echo "All tests passed!"
    exit 0
fi

echo "Some tests failed."
exit 1
