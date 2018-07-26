#!/bin/bash
## APIKEY obtained from Namesilo:
APIKEY="YOUR_KEY_HERE"
CACHE="tmp/"
RESPONSE="tmp/namesilo_response.xml"

## DO NOT EDIT BELOW THIS LINE ##

## https://stackoverflow.com/questions/59895
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE"  ]; do
  DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /*  ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"

echo "Recieved request for" "${CERTBOT_DOMAIN}"
cd ${DIR}

DOMAIN=${CERTBOT_DOMAIN}
VALIDATION=${CERTBOT_VALIDATION}
## Get the XML & record ID
curl -s "https://www.namesilo.com/api/dnsListRecords?version=1&type=xml&key=$APIKEY&domain=$DOMAIN" > $CACHE$DOMAIN.xml
## Check for existing ACME record
if grep -q "_acme-challenge" $CACHE$DOMAIN.xml
then
	## Get record ID
    RECORD_ID=`xmllint --xpath "//namesilo/reply/resource_record/record_id[../host/text() = '_acme-challenge.$DOMAIN' ]" $CACHE$DOMAIN.xml | grep -oP '(?<=<record_id>).*?(?=</record_id>)'`
	## Update DNS record in Namesilo:
	curl -s "https://www.namesilo.com/api/dnsUpdateRecord?version=1&type=xml&key=$APIKEY&domain=$DOMAIN&rrid=$RECORD_ID&rrhost=_acme-challenge&rrvalue=$VALIDATION&rrttl=3600" > $RESPONSE
	RESPONSE_CODE=`xmllint --xpath "//namesilo/reply/code/text()"  $RESPONSE`
	## Process response, maybe wait
	case $RESPONSE_CODE in
		300)
			echo "Update success. Please wait 15 minutes for validation..."
			# Records are published every 15 minutes. Wait for 16 minutes, and then proceed.
			for (( i=0; i<16; i++ )); do
				echo "Minute" ${i}
				sleep 60s
			done
			;;
	   280)
		echo "Update aborted, please check your NameSilo account."
			;;
	   *)
		echo "No valid response from Namesilo"
			;;
	esac
else
	## Add the record
	curl -s "https://www.namesilo.com/api/dnsAddRecord?version=1&type=xml&key=$APIKEY&domain=$DOMAIN&rrtype=TXT&rrhost=_acme-challenge&rrvalue=$VALIDATION&rrttl=3600" > $RESPONSE
	RESPONSE_CODE=`xmllint --xpath "//namesilo/reply/code/text()"  $RESPONSE`
	## Process response, maybe wait
	case $RESPONSE_CODE in
		300)
			echo "Addition success. Please wait 15 minutes for validation..."
			# Records are published every 15 minutes. Wait for 16 minutes, and then proceed.
			for (( i=0; i<16; i++ )); do
				echo "Minute" ${i}
				sleep 60s
			done
			;;
	   280)
		echo "DNS addition aborted, please check your NameSilo account."
			;;
	   *)
		echo "No valid response from Namesilo"
			;;
	esac
fi
