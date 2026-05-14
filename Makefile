CC ?= gcc 
CFLAGS ?= -Wall -Wextra -g 

TARGET = riscv-log-analyzer

.PHONY: all clean test help

help:
	@echo "Available Targets:"
	@echo "all   	Run the analyzer on all test log files"
	@echo "test  	Run the analyzer on each test_data file and verify expected output"
	@echo "report	Generate a summary report in output/"
	@echo "clean 	Remove all generated output files"
	@echo "help  	Print all available targets with descriptions"
	@echo "setup 	Check that all required tools (bash, grep, awk, etc.) are installed"