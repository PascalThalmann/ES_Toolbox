#!/bin/bash

user_old=$1
password_old=$2
old_cluster=$3
user_new=$4
password_new=$5
new_cluster=$6

file="../config/reindex.cfg"
timeout="600m"
timestamp=`date +%Y-%m-%d-%H:%M:%S`
log="/var/tmp/reindex.sh_${timestamp}.log"

generate_post_data()
{
  index=$1
  cat <<EOF
    {
    "source": {
      "remote": {
        "host": "https://${old_cluster}:9200/",
        "username": "${user_old}",
        "password": "${password_old}"
      },
      "index": "${index}"
    },
    "dest": {
      "index": "${index}",
      "op_type": "create",
      "version_type": "external"
    }
  }
EOF
}

for index in `cat $file`
do
  start_time=`date +%Y.%m.%d"  "%H:%M:%S`
  echo -e "\n--------------------\n working on $index at: ${start_time}" | tee -a ${log}
  curl -i \
  -H "Accept: application/json" \
  -H "Content-Type:application/json" \
  -XPOST --data "$(generate_post_data $index)" -u ${user_new}:${password_new} http://${new_cluster}:9200/_reindex?timeout=${timeout}
done

echo -ne "\n--------------------\n" | tee -a ${log}
