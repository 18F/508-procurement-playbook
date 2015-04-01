# MAX_ERRORS=0
# MAX_WARNINGS=10
# MAX_NOTICES=1000
# STANDARD="WCAG2AAA"

nohup http-server -p 8080 >/dev/null 2>&1 &
pa11y -s $PA11Y_STANDARD -r json localhost:8080/index.html > pa11y.json

function count_type () {
  cat pa11y.json | json count.$1
}

error_count=`count_type "error"`
warning_count=`count_type "warning"`
notice_count=`count_type "notice"`

fail=false

if [ "$error_count" -le "$MAX_PA11Y_ERRORS" ]
then
  echo "$PA11Y_STANDARD errors passed"
else
  echo "$PA11Y_STANDARD errors failed: expected $MAX_PA11Y_ERRORS errors, got $error_count"
  fail=true
fi

if [ "$warning_count" -le "$MAX_PA11Y_WARNINGS" ]
then
  echo "$PA11Y_STANDARD warnings passed"
else
  echo "$PA11Y_STANDARD warnings failed: expected $MAX_PA11Y_WARNINGS warnings, got $warning_count"
  fail=true
fi

if [ "$notice_count" -le "$MAX_PA11Y_NOTICES" ]
then
  echo "$PA11Y_STANDARD notices passed"
else
  echo "$PA11Y_STANDARD notices failed: expected $MAX_PA11Y_NOTICES notices, got $notice_count"
  fail=true
fi

echo "See the pa11y report for details:"
cat pa11y.json | json

if [ $fail == true ]
then
  exit 1
fi

rm pa11y.json

