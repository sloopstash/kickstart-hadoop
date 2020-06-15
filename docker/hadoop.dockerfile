# pull core image.
FROM amazonlinux:2

# install system packages.
RUN set -x \
  && yum update -y \
  && yum install -y wget vim net-tools initscripts gcc make tar bind-utils nc \
  && yum install -y python-devel python-setuptools \
  && easy_install supervisor pip \
  && mkdir /etc/supervisord.d

# install openssh server and passwd.
RUN yum install -y openssh-server openssh-clients passwd

# configure openssh server.
RUN set -x \
  && mkdir /var/run/sshd \
  && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' \
  && sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# switch work directory.
WORKDIR /tmp

# install oracle java development kit.
COPY downloads/jdk-8u131-linux-x64.rpm ./
RUN set -x \
  && rpm -Uvh jdk-8u131-linux-x64.rpm \
  && rm -rf jdk-8u131-linux-x64.rpm

# create user named hadoop.
RUN set -x \
  && useradd -m -s /bin/bash -d /usr/local/lib/hadoop hadoop

# configure openssh user.
RUN set -x \
  && mkdir /usr/local/lib/hadoop/.ssh \
  && touch /usr/local/lib/hadoop/.ssh/authorized_keys \
  && touch /usr/local/lib/hadoop/.ssh/config \
  && chmod 400 /usr/local/lib/hadoop/.ssh/config
ADD secrets/hadoop.pub /usr/local/lib/hadoop/.ssh/authorized_keys

# install hadoop.
COPY downloads/hadoop-2.10.0.tar.gz ./
RUN set -x \
  && tar xvzf hadoop-2.10.0.tar.gz > /dev/null \
  && cp -r hadoop-2.10.0/* /usr/local/lib/hadoop/ \
  && chown -R hadoop:hadoop /usr/local/lib/hadoop \
  && rm -rf hadoop-2.10.0.tar.gz hadoop-2.10.0
RUN set -x \
  && mkdir /opt/hadoop \
  && mkdir /opt/hadoop/data \
  && mkdir /opt/hadoop/data/tmp \
  && mkdir /opt/hadoop/data/hdfs \
  && mkdir /opt/hadoop/data/hdfs/namenode \
  && mkdir /opt/hadoop/data/hdfs/datanode \
  && mkdir /opt/hadoop/log \
  && mkdir /opt/hadoop/system \
  && touch /opt/hadoop/system/process.pid \
  && chown -R hadoop:hadoop /opt/hadoop

# switch work directory.
WORKDIR /
