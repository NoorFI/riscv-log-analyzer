# **RISCV LOG ANALYZER**
## *MEDS Training Programme*
### **Module 1 Grand Assignment Usage Guide**
#### *Script: analyze.sh*

**Basic Usage:**

~~~
./scripts/analyze.sh <logfile>
~~~

**Using additional options:**

~~~
./scripts/analyze.sh <logfile> --format [text|csv] --output <filepath> --verbose
~~~

**Alternative method:**

Utilize help to get a proper breakdown of each argument
~~~
./scripts/analyze.sh --help
~~~
You will see commands like format, output, verbose and help.

**Additional Argument options:**

1. Format:</br>
    This decides how your output would look like.
    csv = comma separated values designed to store tabular data.
   
    ~~~
    --format text
    --format csv
    ~~~

    Default: text

2. Output:</br>
    Decides where to display your output, to shell or to a file.
    ~~~
    --output output/report.txt
    ~~~

    Default: stdout

3. Verbose:</br>
    Enables debug messages.
    
    ~~~
    --verbose
    ~~~

4. Help:</br>
    Displays a help menu with all options explained.
    ~~~
    --help
    ~~~

**Examples:**

Basic run:
~~~
./scripts/analyze.sh test_data/sample_pass.log
~~~

csv output:
~~~
./scripts/analyze.sh test_data/sample_fail.log --format csv
~~~

Save report to a file:
~~~
./scripts/analyze.sh test_data/sample_sim.log --output output/report.txt
~~~

Verbose mode:
~~~
./scripts/analyze.sh test_data/sample_fail.log --verbose
~~~

**Remember:**

Log files must follow the specified format:

~~~
[timestamp] TEST PASS/FAIL/SKIP: name (time)s
~~~
