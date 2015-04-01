portslay () { 
  kill -9 `lsof -i tcp:$1 | tail -1 | awk '{ print $2;}'` 
}

nohup http-server -p 8080 &
pa11y -r csv localhost:8080/index.html > pa11y.csv
cat pa11y.csv
