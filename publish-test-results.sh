#!/bin/sh
if [ $# -lt 4 ]; then
  echo "Usage: $0 [USER] [PASSWORD] [TESTS] [FAILURES]"
  exit 1
fi

user=$1
passwd=$2
tests=$3
failures=$4
date=$(date "+%-d.%-m.%Y")

#
# Clone
#
if ! [ -d minimonitor ]; then
  git clone "https://github.com/$user/minimonitor.git"
fi
if ! [ -d minimonitor ]; then
  echo "FAILURE"
  exit 2
fi
cd minimonitor

#
# Create json
#
echo "{" > text.json
echo "  \"refresh\": 10," >> text.json
if [ $tests -eq 0 ]; then
  echo "  \"text\": {" >> text.json
  echo "       \"big\": \"<font color=\\\"red\\\">Failure!</font>\"," >> text.json
  echo "       \"small\": \"There are no tests.\"," >> text.json
elif [ $tests -gt 0 ] && [ $failures -eq 0 ]; then
  echo "  \"text\": {" >> text.json
  echo "       \"big\": \"<font color=\\\"green\\\">Success!</font>\"," >> text.json
  echo "       \"small\": \"All $tests tests pass.\"," >> text.json
else
  percent=$(echo "100.0*($tests-$failures)/$tests" |bc)
  echo "  \"text\": {" >> text.json
  echo "       \"big\": \"$percent %\"," >> text.json
  echo "       \"small\": \"Currently $failures of $tests tests fail.\"," >> text.json
fi
echo "       \"topright\": \"$date\"" >> text.json
echo "   }" >> text.json
echo "}" >> text.json

#
# Commit and push new data
#
git commit -m "update" text.json
git remote set-url origin "https://$user:$passwd@github.com/$user/minimonitor.git"
git push

