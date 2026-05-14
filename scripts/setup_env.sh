#!/bin/bash 
# My seventh MEDS script 
# Author: Noor Fatima
# Date: 2026-05-14

echo "=== Checking Required Tools ==="

if command -v bash >/dev/null 2>&1; then #Check bash
    echo "bash is installed"
else
    echo "bash is NOT installed"
fi

if command -v grep >/dev/null 2>&1; then #Check grep
    echo "grep is installed"
else
    echo "grep is NOT installed"
fi

if command -v awk >/dev/null 2>&1; then #Check awk
    echo "awk is installed"
else
    echo "awk is NOT installed"
fi

if command -v bc >/dev/null 2>&1; then #Check bc
    echo "bc is installed"
else
    echo "bc is NOT installed"
fi

echo "=== Environment Check Complete ==="