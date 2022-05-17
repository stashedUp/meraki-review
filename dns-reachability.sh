#!/bin/bash

filename='/etc/resolv.conf'
endpoint='www.meraki.com'
nameserverArr=()
while IFS= read -r line;
do    
    if [[ $line =~ ^nameserver* ]];then
        nameserver=$(awk '{print $2}' <<< "$line")
        nameserverArr+=("$nameserver")
    fi
done < $filename

if [ ${#nameserverArr[@]} -eq 0 ]; then
    echo "No nameserver found. Nothing to do"
    exit 0
fi


for nameserver in "${nameserverArr[@]}"; do
    time=$(dig @$nameserver +time=1 $endpoint | grep "Query time" | awk -F : '{print $2}' | tr -d "msec" | tr -d " ")
    case $(echo $?) in
    0)
        # code if found
        echo "$(date +%s),$nameserver,succeded,$time"
        ;;
    1)
        # code if not found
        echo "$(date +%s),$nameserver,failed,$time"
        ;;
    *)
        # code if an error occurred
        ;;
    esac
done
