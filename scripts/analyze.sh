#!/bin/bash 
# My fifth MEDS script 
# Author: Noor Fatima 
# Date: 2026-05-12

set -euo pipefail

file_validation("$@"){
    if [ "$#" -ne 1 ]; then
        echo "No argument provided"
        exit 1
    fi

    logfilepath=$1

    if [ ! -f "$logfilepath" ]; then
        echo "File does not exist"
        exit 1
    fi
    # If file is unreadable but dont know how to check that yet.
}

additional_arguments("$@"){
    --format=text
    --output=stdout
    --verbose=0
    --help=0

    while [ $# -gt 0 ]; do
        if [ "$2" = "--format" ]; then
            --format=$3
            shift 2
        fi

        if [ "$2" = "--output" ]; then
            --output=$3
            shift 2
        fi

        if [ "$2" = "--verbose" ]; then
            --verbose=1
            shift 1
        fi

        if [ "$2" = "--help" ]; then
            --help=1
            shift 1
        fi
    done
}

log_analysis("$@"){
    PASS=$(grep -c 'PASS' "$logfilepath")
    FAIL=$(grep -c 'FAIL' "$logfilepath")
    SKIP=$(grep -c 'SKIP' "$logfilepath")

    TOTAL=$($PASS + $FAIL + $SKIP)
}

statistics("$@"){
    if [ "$TOTAL" -gt 0 ]; then
        PASS_RATE=("$PASS"/"$TOTAL") * 100
    fi

    FAIL_LIST=$(grep 'FAIL' "$logfilepath" | awk '{print $4}' "$logfilepath")
    EXEC_TIME=$(grep -v 'SKIP' "$logfilepath" | awk '{print $5}' "$logfilepath")
}

report("$@"){
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
}

exit_code("$@"){
    if [ "FAIL" -gt 0 ]; then
        echo "--- Verdict: PASS ---"
        echo "Exit code: 0"
        exit 0
    else
        echo "--- Verdict: FAIL ---"
        echo "Exit code: 1"
        exit 1
    fi
}

file_validation()
additional_arguments()
log_analysis()
statistics()
report()
exit_code()