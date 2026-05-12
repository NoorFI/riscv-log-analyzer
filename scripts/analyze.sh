#!/bin/bash 
# My fifth MEDS script 
# Author: Noor Fatima 
# Date: 2026-05-12

set -euo pipefail

if [ -z "$1" ]; then
    echo "No argument provided"
    exit 1
fi

logfilepath=$1

if [ ! -d "$logfilepath" ]; then
    echo "Directory does not exist"
    exit 1
fi

additional_arguments(){
    format=text
    output=stdout
    verbose=False
    help=False

    while [ $# -gt 0 ]; do
        if [ "$1" = "format" ]; then
            format=$2
        fi

        if [ "$1" = "output" ]; then
            output=$2
        fi

        if [ "$1" = "verbose" ]; then
            verbose=True
        fi

        if [ "$1" = "help" ]; then
            help=True
        fi
    done
}

statistics(){
    if [ "$TOTAL" -gt 0 ]; then
        PASS_RATE=("$PASS"/"$TOTAL") * 100
    fi

    FAIL_LIST=$(grep "FAIL" "$logfilepath" | cut -d':' -f3 "$logfilepath")
    EXEC_TIME=$(! grep "SKIP" "$logfilepath" | cut -d -f4 "$logfilepath")
}

PASS=$(grep -c 'PASS' "$logfilepath")
FAIL=$(grep -c 'FAIL' "$logfilepath")
SKIP=$(grep -c 'SKIP' "$logfilepath")

TOTAL=$(wc -l "$logfilepath")

additional_arguments()
statistics()

if [ "format" = "text" ]; then
    echo "=== RISC-V Simulation Log Analysis ==="
    echo "Log file: $logfilepath"
    echo "Analysis date: $(date)"

    echo "--- Results Summary ---"
    echo "Total tests: $TOTAL"
    echo "Passed:       $PASS ($PASS_RATE)"
    echo "Failed:       $FAIL ($FAIL_RATE)"
    echo "Skipped:      $SKIP ($SKIP_RATE)"

    echo "--- Failed Tests ---"
    echo "$FAIL"

    echo "--- Timing Statistics ---"
    echo "Min time:     $EXEC_TIME"
    echo "Max time:     $EXEC_TIME"
    echo "Avg time:     $EXEC_TIME"
fi

if [ "FAIL" -gt 0 ]; then
    echo "--- Verdict: PASS ---"
    echo "Exit code: 0"
    exit 0
else
    echo "--- Verdict: FAIL ---"
    echo "Exit code: 1"
    exit 1
fi