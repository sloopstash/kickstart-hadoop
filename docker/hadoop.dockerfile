# pull core image.
FROM amazonlinux:2

# install system packages.
RUN set -x \
  && yum update -y \
  && yum install -y wget vim net-tools initscripts gcc make tar bind-utils nc \
  && yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel openssh-server openssh-clients passwd \
  && yum install -y python-devel python-setuptools \
  && easy_install supervisor pip \
  && mkdir /etc/supervisord.d \
  && history -c

# switch work directory.
WORKDIR /tmp

# create user named hadoop.
RUN set -x \
  && useradd -m -s /bin/bash -d /usr/local/lib/hadoop hadoop

# configure openssh server.
RUN set -x \
  && mkdir /var/run/sshd \
  && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' \
  && sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# configure openssh user.
RUN set -x \
  && mkdir /usr/local/lib/hadoop/.ssh \
  && touch /usr/local/lib/hadoop/.ssh/authorized_keys \
  && touch /usr/local/lib/hadoop/.ssh/config \
  && chmod 400 /usr/local/lib/hadoop/.ssh/config
ADD secret/hadoop.pub /usr/local/lib/hadoop/.ssh/authorized_keys

# install hadoop.
RUN set -x \
  && wget -q http://apachemirror.wuchna.com/hadoop/common/hadoop-2.10.0/hadoop-2.10.0.tar.gz \
  && tar xvzf hadoop-2.10.0.tar.gz > /dev/null \
  && cp -r hadoop-2.10.0/* /usr/local/lib/hadoop/ \
  && chown -R hadoop:hadoop /usr/local/lib/hadoop \
  && rm -rf hadoop-2.10.0.tar.gz hadoop-2.10.0 \
  && history -c
RUN set -x \
  && mkdir /opt/hadoop \
  && mkdir /opt/hadoop/data \
  && mkdir /opt/hadoop/log \
  && mkdir /opt/hadoop/script \
  && chown -R hadoop:hadoop /opt/hadoop \
  && history -c

# switch work directory.
WORKDIR /
