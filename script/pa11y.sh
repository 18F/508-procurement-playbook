# Don't allow errors to remain silent
# Read more:http://www.davidpashley.com/articles/writing-robust-shell-scripts/#id2382181
set -e 

# Settings
MAX_PA11Y_ERRORS=0
MAX_PA11Y_NOTICES=0
MAX_PA11Y_WARNINGS=1000
PA11Y_STANDARD='WCAG2AAA'  
PAGES=('index.html')

if [[ -z "$TRAVIS" ]];
then
  echo
else
  npm install -g pa11y
  npm install -g http-server
  npm install -g json
fi

# This lets us output colored text
red=`tput setaf 1`
green=`tput setaf 2`
blue=`tput setaf 4`
reset=`tput sgr0`

# Start the local static server, make it run in the background
nohup http-server -p 8080 >/dev/null 2>&1 &

# Usage:
#   test_page "index.html"
function test_page () {
  # Run the pa11y test, save report to a json file
  url=localhost:8080/$1
  pa11y -s $PA11Y_STANDARD -r json $url > pa11y.json

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
      echo "${green}  $PA11Y_STANDARD $1 passed. Threshold: $2, found: $3 ${reset}"
    else
      echo "${red}  $PA11Y_STANDARD $1 failed: expected $2, got $3 ${reset}"
      fail=true
    fi
  }

  fail=false

  error_count=`count_type "error"`
  warning_count=`count_type "warning"`
  notice_count=`count_type "notice"`

  echo "pa11y results for $1:"
  report_results "errors" $MAX_PA11Y_ERRORS $error_count
  report_results "warnings" $MAX_PA11Y_WARNINGS $warning_count
  report_results "notices" $MAX_PA11Y_NOTICES $notice_count
  echo

  echo "pa11y report:"
  cat pa11y.json | json

  rm pa11y.json
}

for page in ${PAGES[*]};
do
  test_page $page
done

if [[ $fail == true ]]
then
  exit 1
fi