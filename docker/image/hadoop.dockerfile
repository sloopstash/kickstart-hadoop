# Docker image to use.
FROM sloopstash/amazonlinux:v1

# Switch work directory.
WORKDIR /tmp

# Install Oracle JDK.
COPY jdk-8u131-linux-x64.rpm ./
RUN set -x \
  && rpm -Uvh jdk-8u131-linux-x64.rpm \
  && rm -rf jdk-8u131-linux-x64.rpm

# Create system user for Hadoop.
RUN set -x \
  && useradd -m -s /bin/bash -d /usr/local/lib/hadoop hadoop

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
