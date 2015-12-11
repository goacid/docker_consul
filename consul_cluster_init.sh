#!/bin/bash
for entry in $(etcdctl ls /registrator --recursive 2>/dev/null) ;
do
  b=$(grep -Eo "[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}" <<< ${entry})$(etcdctl get ${entry} 2>/dev/null|grep "10.*:53");
  a+=" "$b;
done;
c=$(echo $a|tr " " "\\n"|sort|uniq|sed -re "s/(^10.[0-9.]*):.*/-retry-join=\\1/");
if [[ $c ]]; then
  total_server="$(echo ${c} | tr " " "\n"| grep -c join )"
  if [[  ${total_server} < 3 ]]; then
    echo "CONSUL_START=-server $c"
  else
    echo "CONSUL_START=$c"
  fi
else
  echo "CONSUL_START=-server -bootstrap-expect 3"
fi

