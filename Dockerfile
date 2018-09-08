#FROM alpine:3.6
FROM centos:latest
MAINTAINER Ivan Ermilov <ivan.s.ermilov@gmail.com>

HEALTHCHECK CMD curl -f http://localhost:50070/ || exit 1

MAINTAINER Newnius <newnius.cn@gmail.com>

# use root directlly as there is no security issues in containers (use root or not)
USER root

# install required packages
#RUN apk add --no-cache openssh openssl openjdk8-jre rsync bash procps
RUN  yum install -y  openssh openssh-clients openssh-server openssl java-1.8.0-openjdk-devel rsync bash procps wget which

# set JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk
#ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.181-3.b13.el7_5.x86_64/jre
ENV PATH $PATH:$JAVA_HOME/bin

# configure passwordless SSH
#RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys


#configur ssh for container in cluster.
ADD ssh_config /root/.ssh/config
ADD sshd_config /etc/ssh

RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

#EXPOSE 8088 50070 22 8020
RUN echo "Port 22" >> /etc/ssh/sshd_config
#RUN /usr/sbin/sshd

# install Hadoop
RUN wget -O hadoop.tar.gz https://archive.apache.org/dist/hadoop/common/hadoop-2.7.4/hadoop-2.7.4.tar.gz && \
tar -xzf hadoop.tar.gz -C /usr/local/ && rm hadoop.tar.gz

# create a soft link to make it transparent when upgrade Hadoop
RUN ln -s /usr/local/hadoop-2.7.4 /usr/local/hadoop

# set Hadoop enviroments
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

ENV HADOOP_PREFIX $HADOOP_HOME
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_YARN_HOME $HADOOP_HOME
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
#when hadoop app run on the container, the following variable need to set.
ENV HADOOP_CLASSPATH=$HADOOP_HOME:$HADOOP_CLASSPATH

ENV HDFS_CONF_dfs_namenode_name_dir=file:///hadoop/dfs/name
ENV HDFS_CONF_dfs_datanode_data_dir=file:///hadoop/dfs/data
#create directories on containers for hdfs. 
#container volumes are mounted inside these directories when containers are created.
RUN mkdir -p /hadoop/dfs/name
RUN mkdir -p /hadoop/dfs/data

# add default config files which has one master and three slaves
ADD core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
ADD hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
ADD yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
ADD slaves $HADOOP_HOME/etc/hadoop/slaves

# update JAVA_HOME and HADOOP_CONF_DIR in hadoop-env.sh
RUN sed -i "/^export JAVA_HOME/ s:.*:export JAVA_HOME=${JAVA_HOME}\nexport HADOOP_HOME=${HADOOP_HOME}\nexport HADOOP_PREFIX=${HADOOP_PREFIX}:" ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh
RUN sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

WORKDIR $HADOOP_HOME

RUN chmod +x $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

RUN $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

#ADD bootstrap.sh /etc/bootstrap.sh

#RUN /usr/sbin/sshd            

#CMD ["/etc/bootstrap.sh", "-d"]
#CMD ["/usr/sbin/sshd"]
CMD ["sh", "-c", "/usr/sbin/sshd; bash"]

