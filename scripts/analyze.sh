#!/bin/bash 
# My fifth MEDS script 
# Author: Noor Fatima 
# Date: 2026-05-12

set -euo pipefail

file_validation(){
    if [ "$#" -lt 1 ]; then
        echo "No argument provided"
        exit 1
    fi

    logfilepath=$1

    if [ ! -r "$logfilepath" ]; then
        echo "File does not exist or isn't readable"
        exit 1
    fi
}

additional_arguments(){
    format=text
    output=stdout
    verbose=0
    help=0
    shift 1

    while [ $# -gt 0 ]; do
        if [ "$1" = "--format" ]; then
            if [ -z "$2" ]; then
                echo "No format provided"
                exit 1
            fi
            format=$2
            shift 2
        elif [ "$1" = "--output" ]; then
            if [ -z "$2" ]; then
                echo "No output provided"
                exit 1
            fi
            output=$2
            shift 2
        elif [ "$1" = "--verbose" ]; then
            verbose=1
            shift 1
        elif [ "$1" = "--help" ]; then
            help=1
            shift 1
        else
            exit 1
        fi
    done
}

log_analysis(){
    PASS=$(grep -c 'TEST PASS:' "$logfilepath")
    FAIL=$(grep -c 'TEST FAIL:' "$logfilepath")
    SKIP=$(grep -c 'TEST SKIP:' "$logfilepath")

    TOTAL=$((PASS + FAIL + SKIP))
}

statistics(){
    if [ "$TOTAL" -gt 0 ]; then
        PASS_RATE=$(awk "BEGIN {print ($PASS/$TOTAL)*100}")
        FAIL_RATE=$(awk "BEGIN {print ($FAIL/$TOTAL)*100}")
        SKIP_RATE=$(awk "BEGIN {print ($SKIP/$TOTAL)*100}")
    fi

    FAIL_LIST=$(grep 'TEST FAIL:' "$logfilepath" | awk '{print $5}')
    EXEC_TIME=0
    MIN_TIME=100
    MAX_TIME=0
    AVG_TIME=0

    while IFS= read -r line; do 
        if grep -q "TEST PASS:" <<< "$line"; then
            EXEC_TIME=$(echo "$line" | awk '{print $6}')
        elif grep -q "TEST FAIL:" <<< "$line"; then
            EXEC_TIME=$(echo "$line" | awk '{print $6}')
        else
            exit 1
        fi

        EXEC_TIME=$(echo "$EXEC_TIME" | tr -d '()' | tr -d 's')
        

        if [ "$(echo "$EXEC_TIME < $MIN_TIME" | bc -l)" -eq 1 ]; then
            MIN_TIME=$EXEC_TIME
        fi
        
        if [ "$(echo "$EXEC_TIME > $MAX_TIME" | bc -l)" -eq 1 ]; then
            MAX_TIME=$EXEC_TIME
        fi

        AVG_TIME=$(echo "$AVG_TIME / $SUM" | bc -l)
    done < "$logfilepath"

    SUM=$((PASS + FAIL))
    AVG_TIME=$((AVG_TIME / SUM))
}

report(){
    if [ "$format" = "text" ]; then
        echo "=== RISC-V Simulation Log Analysis ==="
        echo "Log file: $logfilepath"
        echo "Analysis date: $(date)"

        echo "--- Results Summary ---"
        echo "Total tests: $TOTAL"
        echo "Passed:       $PASS ($PASS_RATE)"
        echo "Failed:       $FAIL ($FAIL_RATE)"
        echo "Skipped:      $SKIP ($SKIP_RATE)"

        echo "--- Failed Tests ---"
        echo "$FAIL_LIST"

        echo "--- Timing Statistics ---"
        echo "Min time:     $MIN_TIME"
        echo "Max time:     $MAX_TIME"
        echo "Avg time:     $AVG_TIME"
    elif [ "$format" = "csv" ]; then
        echo "Log file, Analysis date, Total tests, Passed, Failed, Skipped, List of failed tests, Min time, Max time, Avg time"
        echo "$logfilepath, $(date), $TOTAL, $PASS ($PASS_RATE), $FAIL ($FAIL_RATE), $SKIP ($SKIP_RATE), $FAIL_LIST, $MIN_TIME, $MAX_TIME, $AVG_TIME"
    fi
}

exit_code(){
    if [ "$FAIL" -gt 0 ]; then
        echo "--- Verdict: FAIL ---"
        echo "Exit code: 1"
        exit 1
    else
        echo "--- Verdict: PASS ---"
        echo "Exit code: 0"
        exit 0
    fi
}

file_validation("$@")
additional_arguments("$@")
log_analysis("$@")
statistics("$@")
report("$@")
exit_code("$@")