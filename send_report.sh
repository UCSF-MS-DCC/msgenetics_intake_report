#!/bin/bash

DATE=`date +'%m-%d-%Y'`

echo "Summary of completed RedCap intake surveys" | mailx -s "MS Genetics Redcap Report" -a ./report.pdf adam.renschen@ucsf.edu
echo "Summary of completed RedCap intake surveys" | mailx -s "MS Genetics Redcap Report" -a ./report.pdf stacy.callier@ucsf.edu
mv ./report.pdf ./reports/report_$DATE.pdf
