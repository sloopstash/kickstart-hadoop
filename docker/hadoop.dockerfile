# Docker image to use.
FROM sloopstash/amazonlinux:v1

# Install OpenSSH server and Git.
RUN yum install -y openssh-server passwd git

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
ADD secret/node.pub /usr/local/lib/hadoop/.ssh/authorized_keys

# Switch work directory.
WORKDIR /tmp

# Install Oracle JDK.
COPY jdk-8u131-linux-x64.rpm ./
RUN set -x \
  && rpm -Uvh jdk-8u131-linux-x64.rpm \
  && rm -rf jdk-8u131-linux-x64.rpm

# Install Hadoop.
COPY hadoop-2.10.1.tar.gz ./
RUN set -x \
  && tar xvzf hadoop-2.10.1.tar.gz > /dev/null \
  && cp -r hadoop-2.10.1/* /usr/local/lib/hadoop/ \
  && chown -R hadoop:hadoop /usr/local/lib/hadoop \
  && rm -rf hadoop-2.10.1.tar.gz hadoop-2.10.1
RUN set -x \
  && mkdir /opt/hadoop \
  && mkdir /opt/hadoop/data \
  && mkdir /opt/hadoop/log \
  && mkdir /opt/hadoop/script \
  && mkdir /opt/hadoop/system \
  && mkdir /opt/hadoop/tmp \
  && touch /opt/hadoop/system/process.pid \
  && chown -R hadoop:hadoop /opt/hadoop

# Switch work directory.
WORKDIR /

# Cleanup history.
RUN history -c
