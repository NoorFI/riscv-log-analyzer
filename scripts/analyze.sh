#!/bin/bash 
# My fifth MEDS script 
# Author: Noor Fatima
# Date: 2026-05-12

set -euo pipefail
#Here e is exit if any command gives a non-zero status,
#u is usage of undefined variables as errors,
#pipefail basically means inside a pipeline if any command fails the whole thing fails.

format=text
output=stdout
verbose=0
help=0
compare=0 #In all three of these 0 is considered as undefined/unspecified.
logfilepath=""
compare_file=""
RED=$'\033[31m'
GREEN=$'\033[32m' #ANSI Escape codes for pass and fail outputs.
RESET=$'\033[0m' #Always appended to stop colouring.

help_menu(){
    verbose_message "Displaying help menu"

    echo "Usage:"
    echo "./analyze.sh <logfile> [additional options]"
    echo
    echo "Additional Options:"
    echo "--format [text|csv]    Output format"
    echo "--output <path>        Write output to file"
    echo "--verbose              Enable verbose mode"
    echo "--help                 Show help menu"
    echo "--compare <old_log>    Compare logs and show regressions"
}

verbose_message(){
    #Verbose method is essentially similar to walking through the debugging process with proper messages on each stage.
    if [ "$verbose" -eq 1 ]; then
        echo "[VERBOSE] $1"
    fi
}

additional_arguments(){
    #This entire function is very similar to normal programming while functions and argument parsing.
    while [ $# -gt 0 ]; do

        if [ "$1" = "--format" ]; then
            
            if [ $# -lt 2 ]; then
                echo "No format provided"
                exit 1
            fi

            format=$2

            if [ "$format" != "text" ] && [ "$format" != "csv" ]; then
                echo "Invalid format"
                exit 1
            fi

            shift 2

        elif [ "$1" = "--output" ]; then
            
            if [ $# -lt 2 ]; then
                echo "No output provided"
                exit 1
            fi

            output=$2
            shift 2
        
        elif [ "$1" = "--compare" ]; then
            
            if [ $# -lt 2 ]; then
                echo "No compare file provided"
                exit 1
            fi
            
            compare=1
            compare_file="$2"
            shift 2

        elif [ "$1" = "--verbose" ]; then
            verbose=1
            shift 1

        elif [ "$1" = "--help" ]; then
            help=1
            shift 1
        else
            if [ -z "$logfilepath" ]; then #In the initial versions this was inside file validation however when writing help and verbose it had to be shifted for easier implementation.
                logfilepath=$1
            else
                echo "Unknown argument: $1"
                exit 1
            fi
            shift 1
        fi
    done

    if [ "$help" -eq 1 ]; then
        help_menu
        exit 0
    fi
}

file_validation(){
    if [ -z "$logfilepath" ]; then
        echo "No log file provided"
        exit 1
    fi

    logfilepath="$(realpath "$logfilepath")" #Ensures absolute path, since we're working from root directory and file is inside another directory.

    if [ ! -r "$logfilepath" ]; then #-r checks for readability and availability of file.
        echo "File does not exist or isn't readable"
        exit 1
    fi

    if [ "$compare" -eq 1 ] && [ ! -r "$compare_file" ]; then #This ensures that if a compare file is provided it is readable
        echo "Compare file does not exist or isn't readable"
        exit 1
    fi
}

log_analysis(){
    verbose_message "Starting log analysis"
    
    verbose_message "Counting PASS/FAIL/SKIP tests"
    PASS=$(grep -c 'TEST PASS:' "$logfilepath" || true)
    FAIL=$(grep -c 'TEST FAIL:' "$logfilepath" || true)
    SKIP=$(grep -c 'TEST SKIP:' "$logfilepath" || true) #Added OR true because -e would cause a script failure if grep found no match for PASS, FAIL or SKIP.

    verbose_message "Calculating Total tests"
    TOTAL=$((PASS + FAIL + SKIP))
}

statistics(){
    verbose_message "Calculating percentages of passed, failed and skipped tests"
    if [ "$TOTAL" -eq 0 ]; then #Originally was checking for when it was gt 0 but this is much more efficient.
        PASS_RATE=0
        FAIL_RATE=0
        SKIP_RATE=0
        MIN_TIME=0
        MAX_TIME=0
        AVG_TIME=0
        FAIL_LIST=""
        return
    fi

    PASS_RATE=$(awk "BEGIN {printf \"%.2f\", ($PASS/$TOTAL)*100}") #printf is added to format the result to exactly 2 decimal places.
    FAIL_RATE=$(awk "BEGIN {printf \"%.2f\", ($FAIL/$TOTAL)*100}") #BEGIN blocks execute immediately.
    SKIP_RATE=$(awk "BEGIN {printf \"%.2f\", ($SKIP/$TOTAL)*100}") #The manual specified only calculating pass rate however the example output shows all 3.

    verbose_message "Generating list of all failed tests"
    FAIL_LIST=$(grep 'TEST FAIL:' "$logfilepath" | awk '{print $5}')

    EXEC_TIME=0
    MIN_TIME=100 #A better way would be to put min and max time as the first execution time however this is an approach we used a lot even though it is hardcoded so for my own ease used this.
    MAX_TIME=0
    AVG_TIME=0
    MIN_TEST_NAME=""
    MAX_TEST_NAME="" #The manual has proper names of tests that have max and min time.

    verbose_message "Calculating timing statistics"
    while IFS= read -r line; do #This reads line by line, without trimming whitespaces and backslash escaping.
        if grep -q "TEST PASS:" <<< "$line"; then
            EXEC_TIME=$(echo "$line" | awk '{print $6}')
        elif grep -q "TEST FAIL:" <<< "$line"; then
            EXEC_TIME=$(echo "$line" | awk '{print $6}')
        else
            continue #This helps skip iterating over lines that are errors summaries warnings or skipped tests.
        fi

        TEST_NAME=$(echo "$line" | awk '{print $5}') #Extracting test names for min and max.
        EXEC_TIME=$(echo "$EXEC_TIME" | tr -d '()' | tr -d 's')
        #This cleans the execution time string so that they can be used for arithmetic operations below.

        if [ "$(echo "$EXEC_TIME < $MIN_TIME" | bc -l)" -eq 1 ]; then #bc -l returns a 1 if the evaluation is true and 0 if false
            MIN_TIME=$EXEC_TIME
            MIN_TEST_NAME=$TEST_NAME
        fi
        
        if [ "$(echo "$EXEC_TIME > $MAX_TIME" | bc -l)" -eq 1 ]; then
            MAX_TIME=$EXEC_TIME
            MAX_TEST_NAME=$TEST_NAME
        fi

        AVG_TIME=$(echo "$AVG_TIME + $EXEC_TIME" | bc -l) #All places where floating point is involved bc -l is used.
    done < "$logfilepath"

    SUM=$((PASS + FAIL)) #Skipped tests excluded from average timing calculations.
    if [ "$SUM" -gt 0 ]; then #Avoids division by zero.
        AVG_TIME=$(echo "scale=2; $AVG_TIME / $SUM" | bc -l) #scale 2 keeps 2 decimal places of average time.
    else
        AVG_TIME=0 #If no tests were executed, average time is set to its default value.
    fi
}

report(){
    verbose_message "Generating report"

    REPORT_TEXT="=== RISC-V Simulation Log Analysis ===
    Log file: $logfilepath
    Analysis date: $(date)
    
    --- Results Summary ---
    Total tests: $TOTAL
    ${GREEN}Passed:${RESET}       ${GREEN}$PASS ($PASS_RATE%)${RESET}
    ${RED}Failed:${RESET}       ${RED}$FAIL ($FAIL_RATE%)${RESET}
    Skipped:      $SKIP ($SKIP_RATE%)
    
    --- Failed Tests ---
    ${RED}$FAIL_LIST${RESET}

    --- Timing Statistics ---
    Min time:     ${MIN_TIME}s ($MIN_TEST_NAME)
    Max time:     ${MAX_TIME}s ($MAX_TEST_NAME)
    Avg time:     ${AVG_TIME}s"

    REPORT_CSV="Log file,Analysis date,Total tests,Passed,Failed,Skipped,List of failed tests,Min time,Max time,Avg time
    $logfilepath,$(date),$TOTAL,$PASS ($PASS_RATE),$FAIL ($FAIL_RATE),$SKIP ($SKIP_RATE),$FAIL_LIST,$MIN_TIME $MIN_TEST_NAME,$MAX_TIME $MAX_TEST_NAME,$AVG_TIME"
    
    if [ "$format" = "text" ]; then
        REPORT=$REPORT_TEXT
    elif [ "$format" = "csv" ]; then
        REPORT=$REPORT_CSV
    fi

    if [ "$output" = "stdout" ]; then
        echo "$REPORT"
    else
        echo "$REPORT" > "$output"
        echo "Report written to $output"
    fi
}

compare_logs(){
    verbose_message "Comparing logs for regressions"

    OLD_PASSED_TESTS=$(grep "TEST PASS:" "$compare_file" | awk '{print $5}')
    NEW_FAILED_TESTS=$(grep "TEST FAIL:" "$logfilepath" | awk '{print $5}')

    echo "=== REGRESSIONS (Previously PASS --> Now FAIL) ==="

    for test in $NEW_FAILED_TESTS; do
        if echo "$OLD_PASSED_TESTS" | grep -q "$test"; then
            echo "REGRESSION: $test"
        fi
    done
}

exit_code(){
    verbose_message "Exiting"

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

additional_arguments "$@" #In shell script arguments are passed without any parenthesis.
file_validation "$@"
log_analysis "$@"
statistics "$@"

if [ "$compare" -eq 1 ]; then
    compare_logs "$@"
fi

report "$@"
exit_code "$@" 