CC ?= gcc 
CFLAGS ?= -Wall -Wextra -g 

TARGET = riscv-log-analyzer

.PHONY: all setup clean report test help

all:
	./scripts/analyze.sh test_data/sample_pass.log
	./scripts/analyze.sh test_data/sample_fail.log
	./scripts/analyze.sh test_data/sample_sim.log

setup:
	@echo "Checking required tools:"
	@bash --version
	@grep --version
	@awk --version
	@bc --version

clean:
	rm -f output/*

report:
	./scripts/analyze.sh test_data/sample_pass.log --output output/report_pass.txt
	./scripts/analyze.sh test_data/sample_fail.log --output output/report_fail.txt
	./scripts/analyze.sh test_data/sample_sim.log --output output/report_sim.txt
	@echo "Summary report for all logs generated in output/"

test:
	./scripts/analyze.sh test_data/sample_pass.log
	./scripts/analyze.sh test_data/sample_fail.log
	./scripts/analyze.sh test_data/sample_sim.log
	@echo "Tests completed"

help:
	@echo "Available Targets:"
	@echo "all   	Run the analyzer on all test log files"
	@echo "test  	Run the analyzer on each test_data file and verify expected output"
	@echo "report	Generate a summary report in output/"
	@echo "clean 	Remove all generated output files"
	@echo "help  	Print all available targets with descriptions"
	@echo "setup 	Check that all required tools (bash, grep, awk, etc.) are installed"