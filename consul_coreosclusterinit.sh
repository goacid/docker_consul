#!/bin/sh
if [[ $(fleetctl list-units|egrep ^consul[@][1-3].service) ]]; then 
  run=0 
  for ip in $(fleetctl list-units|egrep ^consul[@][1-3].service|awk '{print $2}'|awk -F'/' '{print $2}'); do
    if [ -n $ip ]; then
      listip[$run]="-retry-join=$ip"
      run+=1
    fi
  done
fi
if [[ $(echo ${#listip[@]}) -eq 0 ]]; then 
  echo  "CONSUL_START=-server -bootstrap-expect 3"
else
  echo "CONSUL_START=${listip[@]}"
fi
source /etc/environment
if [[ $( echo "${listip[@]}" |grep $COREOS_PRIVATE_IPV4) ]]; then
  echo "CONSUL_LOCAL=$COREOS_PRIVATE_IPV4"
else
  echo "CONSUL_LOCAL="
fi
