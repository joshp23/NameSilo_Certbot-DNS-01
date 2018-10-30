#!/bin/bash
# NameSileCertbot-DNS-01 0.2.0
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
source config.sh

DOMAIN=${CERTBOT_DOMAIN}
VALIDATION=${CERTBOT_VALIDATION}

if [ ! -f $CACHE$DOMAIN.xml ] ; then
	curl -s "https://www.namesilo.com/api/dnsListRecords?version=1&type=xml&key=$APIKEY&domain=$DOMAIN" > $CACHE$DOMAIN.xml
fi
## Check for existing ACME record
if grep -q "_acme-challenge" $CACHE$DOMAIN.xml ; then
	## Get record ID
    RECORD_ID=`xmllint --xpath "//namesilo/reply/resource_record/record_id[../host/text() = '_acme-challenge.$DOMAIN' ]" $CACHE$DOMAIN.xml | grep -oP '(?<=<record_id>).*?(?=</record_id>)'`
	## Update DNS record in Namesilo:
	curl -s "https://www.namesilo.com/api/dnsDeleteRecord?version=1&type=xml&key=$APIKEY&domain=$DOMAIN&rrid=$RECORD_ID" > $RESPONSE
	RESPONSE_CODE=`xmllint --xpath "//namesilo/reply/code/text()"  $RESPONSE`
	## Process response, maybe wait
	case $RESPONSE_CODE in
		300)
			echo "ACME challenge record successfully removed"
			;;
	   280)
		echo "Record removal failed, please check your NameSilo account."
			;;
	   *)
		echo "No valid response from Namesilo"
			;;
	esac
fi
if [ -f $RESPONSE ] ; then
    rm $RESPONSE
fi
if [ -f $CACHE$DOMAIN.xml ] ; then
    rm $CACHE$DOMAIN.xml
fi
