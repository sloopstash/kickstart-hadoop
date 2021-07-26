#!/bin/bash

if [ ! -d '/opt/hadoop/data/hdfs' ]; then
  /usr/local/lib/hadoop/bin/hdfs namenode -format
fi
/usr/local/lib/hadoop/sbin/hadoop-daemon.sh start namenode
