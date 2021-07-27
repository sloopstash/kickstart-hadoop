#!/bin/bash
##
# A Shell script to manage Hadoop storage paths that are
# consumed by local Kubernetes volumes.
##

# Only allow root user to execute the script.
if [ `whoami` == 'root' ]; then
  sleep 1;
else
  printf "Please run this script as root or sudo.\n\n";
  exit 1;
fi

# Create Hadoop storage paths.
function create() {
  mkdir -p /mnt/kubernetes/hadoop/data/master/1
  mkdir -p /mnt/kubernetes/hadoop/data/slave/1
  mkdir -p /mnt/kubernetes/hadoop/data/slave/2
  mkdir -p /mnt/kubernetes/hadoop/data/slave/3
  chmod -R ugo+rwx /mnt/kubernetes/hadoop
  chown -R $1:$1 /mnt/kubernetes/hadoop
}

# Delete Hadoop storage paths.
function delete() {
  rm -rf /mnt/kubernetes/hadoop
}

# Choose an operation.
case $1 in
  create)
    create $2;
    ;;
  delete)
    delete;
    ;;
  *)
    echo "Usage: ./storage.sh {create|delete}"
    exit 1;
    ;;
esac
