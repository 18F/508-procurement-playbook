# Set up some defaults to run locally (not on Travis)
if ! [[ $TRAVIS == true ]]
then
  MAX_PA11Y_ERRORS=0
  MAX_PA11Y_NOTICES=1000
  MAX_PA11Y_WARNINGS=1000
  PA11Y_STANDARD="WCAG2AAA"
fi

function count_type () {
  # $1 type (e.g. "errors")
  cat pa11y.json | json count.$1 
}

function report_results () {
  # $1 type (e.g. "errors")
  # $2 max allowed (e.g. 10)
  # $3 count (e.g. 5)
  if [[ "$3" -le "$2" ]]
  then
    echo "$PA11Y_STANDARD $1 passed. Threshold: $2"
  else
    echo "$PA11Y_STANDARD $1 failed: expected $2 $1, got $3"
    fail=true
  fi
}

# Start the local static server, make it run in the background
nohup http-server -p 8080 >/dev/null 2>&1 &
# Run the pa11y test, save report to a json file
pa11y -s $PA11Y_STANDARD -r json localhost:8080/index.html > pa11y.json

fail=false

error_count=`count_type "error"`
warning_count=`count_type "warning"`
notice_count=`count_type "notice"`

report_results "errors" $MAX_PA11Y_ERRORS $errors_count
report_results "warnings" $MAX_PA11Y_WARNINGS $warnings_count
report_results "notices" $MAX_PA11Y_NOTICES $notices_count

echo "\n"
echo "See the pa11y report for details:"
cat pa11y.json | json

rm pa11y.json
if [ $fail == true ]
then
  exit 1
fi