# **RISCV LOG ANALYZER**
## *MEDS Training Programme*
### **Module 1 Grand Assignment**

**Project Description:**

The riscv-log-analyzer is a shell-based tool that processes RISC-V 
simulation log files, extracts useful information, and generates summary reports.

It is designed as part of a Dev Environment & Git workflow lab (MEDS Module 1).

**Installation:**

Follow these instructions inside bash:

1. Clone the repository:</br>
    ~~~
    git clone https://github.com/<your-username>/riscv-log-analyzer.git
    cd riscv-log-analyzer
    ~~~
2. Make the scripts executable:
    ~~~
    chmod +x scripts/analyze.sh
    chmod +x scripts/setup_env.sh
    chmod +x scripts/generate_report.sh
    ~~~
3. Verify dependencies:
    ~~~
    bash --version
    grep --version
    awk --version
    bc --version
    ~~~
    Alternative way:
    ~~~
    make setup
    ~~~

**Usage:**

Basic usage:
~~~
./scripts/analyze.sh test_data/sample_pass.log
~~~
Using additional options:
~~~
./scripts/analyze.sh test_data/sample_fail.log --format csv --output output/report.csv --verbose
~~~
Utilize help to get a proper breakdown of each argument:
~~~
./scripts/analyze.sh --help
~~~
You will see commands like format, output, verbose and help.

**Sample Output:**

~~~
=== RISC-V Simulation Log Analysis === 
Log file: test_data/sample_fail.log 
Analysis date: 2026-05-05 14:30:00 
 
--- Results Summary --- 
Total tests: 25 
Passed:      22 (88.0%) 
Failed:       2 ( 8.0%) 
Skipped:      1 ( 4.0%)

--- Failed Tests --- 
  1. rv32i-sll 
  2. rv32i-beq 

--- Timing Statistics --- 
Min time:  0.42s (rv32i-nop)
Max time:  2.31s (rv32i-mul) 
Avg time:  0.87s

--- Verdict: FAIL --- 
Exit code: 1 
~~~

Author:</br>
***Noor Fatima***