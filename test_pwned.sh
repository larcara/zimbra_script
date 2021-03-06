#!/bin/bash

function list_breaches {
	breacehs=$(curl --silent --user-agent check_pwned --header "Accept: application/vnd.haveibeenpwned.v2+json" https://haveibeenpwned.com/api/breaches)
	echo $breaches
}

function read_file {
	echo $EMAIL_FILE
	while IFS= read -r line ; do
		EMAIL="$line"
		test_if_pwned;
 	done < "$EMAIL_FILE"
}

function test_if_pwned() {
	PWNED=$(curl --silent --user-agent check_pwned --header "Accept: application/vnd.haveibeenpwned.v2+json" https://haveibeenpwned.com/api/breachedaccount/$EMAIL?truncateResponse=true)
	if [[ ! -z $PWNED ]]; then
	   echo "PWNED - $EMAIL $PWNED"
	fi
	  echo "OK - $EMAIL"
	sleep 2
}

function print_help {
	echo "usage:"
	echo "$0 email_to_test to check if email was pwned"
	echo "$0 list to list breaches "
	echo "$0 FILENAME to check all emails n the file (one per line)"


}

case "$1" in
    *@*.*) EMAIL=$1; test_if_pwned;;
    list)    list_breaches;;
    "")     print_help;;
    *)      EMAIL_FILE=$1; read_file;;
esac
