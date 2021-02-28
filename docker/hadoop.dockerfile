# Docker image to use.
FROM amazonlinux:2

# Install system packages.
RUN set -x \
  && yum update -y \
  && yum install -y wget vim net-tools initscripts gcc make tar bind-utils nc \
  && yum install -y python-devel python-setuptools \
  && easy_install supervisor pip \
  && mkdir /etc/supervisord.d

# Install OpenSSH server.
RUN yum install -y openssh-server openssh-clients passwd

# Configure OpenSSH server.
RUN set -x \
  && mkdir /var/run/sshd \
  && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' \
  && sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Create system user for Hadoop.
RUN set -x \
  && useradd -m -s /bin/bash -d /usr/local/lib/hadoop hadoop

# Configure OpenSSH user.
RUN set -x \
  && mkdir /usr/local/lib/hadoop/.ssh \
  && touch /usr/local/lib/hadoop/.ssh/authorized_keys \
  && touch /usr/local/lib/hadoop/.ssh/config \
  && echo -e "Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile=/dev/null" >> /usr/local/lib/hadoop/.ssh/config \
  && chmod 400 /usr/local/lib/hadoop/.ssh/config
ADD secret/hadoop-node.pub /usr/local/lib/hadoop/.ssh/authorized_keys

# Install Java.
RUN yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel

# Switch work directory.
WORKDIR /tmp

# Install Hadoop.
RUN set -x \
  && wget http://apachemirror.wuchna.com/hadoop/common/hadoop-2.10.0/hadoop-2.10.0.tar.gz --quiet \
  && tar xvzf hadoop-2.10.0.tar.gz > /dev/null \
  && cp -r hadoop-2.10.0/* /usr/local/lib/hadoop/ \
  && chown -R hadoop:hadoop /usr/local/lib/hadoop \
  && rm -rf hadoop-2.10.0.tar.gz hadoop-2.10.0
RUN set -x \
  && mkdir /opt/hadoop \
  && mkdir /opt/hadoop/data \
  && mkdir /opt/hadoop/tmp \
  && mkdir /opt/hadoop/log \
  && mkdir /opt/hadoop/system \
  && mkdir /opt/hadoop/script \
  && touch /opt/hadoop/system/process.pid \
  && chown -R hadoop:hadoop /opt/hadoop

# Switch work directory.
WORKDIR /
