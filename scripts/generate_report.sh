#!/bin/bash 
# My sixth MEDS script 
# Author: Noor Fatima
# Date: 2026-05-14

input="$1"
output="output/report.html"

PASS=$(grep -c "TEST PASS:" "$input")
FAIL=$(grep -c "TEST FAIL:" "$input")
SKIP=$(grep -c "TEST SKIP:" "$input")

cat <<EOF > "$output"
<html>
<head><title>RISC-V Log Analyzer Report</title></head>
<body>
<h1>RISC-V Log Summary:</h1>

<table border="1">
<tr><th>Metric</th><th>Value</th></tr>
<tr><td>PASS</td><td>$PASS</td></tr>
<tr><td>FAIL</td><td>$FAIL</td></tr>
<tr><td>SKIP</td><td>$SKIP</td></tr>
</table>

</body>
</html>
EOF

echo "HTML report generated at $output"