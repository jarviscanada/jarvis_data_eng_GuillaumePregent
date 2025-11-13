#!/bin/bash

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

if [ "$#" -ne 5 ]; then
  echo "Illegal number of parameters"
  exit 1
fi

specs=$(lscpu)
hostname=$(hostname -f)
timestamp=$(vmstat -t | awk '{print $18, $19}' | tail -n1 | xargs)

cpu_number=$(echo "$specs" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$specs" | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$specs" | egrep "^Model name:" | awk '{$1=$2=""; print}' | xargs)
cpu_mhz=$(cat /proc/cpuinfo | grep 'cpu MHz' | awk '{print $4}' | uniq | xargs)
l2_cache=$(echo $(($(echo "$specs" | egrep "^L2 cache:" | awk '{print $3}' | xargs) * 1024)))
total_mem=$(cat /proc/meminfo | egrep "MemTotal:" | awk '{print $2}' | xargs)

insert_stmt="INSERT INTO host_info(hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, \
l2_cache, timestamp, total_mem) VALUES ('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', \
$cpu_mhz, $l2_cache, '$timestamp', $total_mem)"

export PGPASSWORD=$psql_password

psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

exit $?