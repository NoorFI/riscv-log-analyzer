SHELL := /bin/bash
CC ?= gcc 
CFLAGS ?= -Wall -Wextra -g 

TARGET = riscv-log-analyzer

LOGS = test_data/sample_pass.log test_data/sample_fail.log test_data/sample_sim.log

.PHONY: all setup clean report test help

all:
	@for file in $(LOGS); do \
		echo "Running $$file"; \
		./scripts/analyze.sh $$file; \
	done

setup:
	./scripts/setup_env.sh

clean:
	rm -f output/*

report:
	@mkdir -p output
	@echo "=== Combined Report ===" > output/report.txt
	@for file in $(LOGS); do \
		echo "Processing $$file" >> output/report.txt; \
		./scripts/analyze.sh $$file >> output/report.txt; \
		echo "" >> output/report.txt; \
	done

test:
	@echo "Running validation tests..."
	@./scripts/analyze.sh test_data/sample_pass.log | grep -q "Failed:" || (echo "PASS test failed"; exit 1)
	@./scripts/analyze.sh test_data/sample_fail.log | grep -q "Failed:" || (echo "FAIL test failed"; exit 1)
	@./scripts/analyze.sh test_data/sample_sim.log | grep -q "Total tests:" || (echo "SIM test failed"; exit 1)
	@echo "All tests passed"

help:
	@echo "Available Targets:"
	@echo "all   	Run the analyzer on all test log files"
	@echo "test  	Run the analyzer on each test_data file and verify expected output"
	@echo "report	Generate a summary report in output/"
	@echo "clean 	Remove all generated output files"
	@echo "help  	Print all available targets with descriptions"
	@echo "setup 	Check that all required tools (bash, grep, awk, etc.) are installed"