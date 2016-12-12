# Multiple elasticsearch cluster
#
# Version 0.1

FROM centos:latest

ENV CLUSTER_NAME=myCluster \
    MINIMUM_MASTER_NODES=3 \
    NODE_NAME_01=node_01 \
    NODE_NAME_02=node_02 \
    NODE_NAME_03=node_03 \
    NODE_NAME_04=node_04 \
    NODE_NAME_05=node_05 

##======== Elasticsearch =================
## Includes:
##		- elasticsearch
##		- Development tools
##		- java 1.8
##========================================
ADD elasticsearch/elasticsearch.repo /etc/yum.repos.d/
RUN rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch && \
    yum update -y && \
    yum groupinstall -y "Development tools" && \
    yum install -y elasticsearch initscripts sudo which wget java-1.8.0-openjdk.x86_64
##========================================
##==== Build 5 elasticsearch nodes =======
ADD add-new-elasticsearch-node.sh /add-new-elasticsearch-node.sh
RUN sh /add-new-elasticsearch-node.sh ${NODE_NAME_01} 9201 && \
    sh /add-new-elasticsearch-node.sh ${NODE_NAME_02} 9202 && \
    sh /add-new-elasticsearch-node.sh ${NODE_NAME_03} 9203 && \
    sh /add-new-elasticsearch-node.sh ${NODE_NAME_04} 9204 && \
    sh /add-new-elasticsearch-node.sh ${NODE_NAME_05} 9205
##========================================



##======== Apache ========================
RUN yum -y --setopt=tsflags=nodocs update && \
    yum -y --setopt=tsflags=nodocs install httpd && \
    yum clean all 
##========================================

##======= Install php5.6 =================
## Includes:
##		- install default php5.4
##		- upgrade php5.4 to php5.6
##		- install other required php extensions
##========================================
RUN yum install -y php && \
    cd /tmp && wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    rpm -Uvh epel-release-latest-7.noarch.rpm && \
    wget http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
    rpm -Uvh remi-release-7.rpm
 
## Upgrade php from default 5.4 to 5.6
USER root
ADD php5.6/remi.repo /etc/yum.repos.d/remi.repo
RUN yum upgrade -y php* && \
    yum install -y php-gd php-pgsql php-mbstring php-xml php-pecl-json
##========================================
    





EXPOSE 80
EXPOSE 5432

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
