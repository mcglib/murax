FROM tomcat:8.0-jre8

MAINTAINER Yinlin Chen "ylchen@vt.edu"

RUN apt-get update && apt-get -y upgrade

# Install Fedora4
ARG FEDORA_VERSION=4.7.5
ARG FEDORA_TAG=4.7.5
ARG FedoraConfig=
ARG ModeshapeConfig=file-simple
ARG JDBCConfig=

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH

RUN mkdir /mnt/ingest

RUN sed -i '$i<role rolename="fedoraUser"/>$i<role rolename="fedoraAdmin"/>$i<role rolename="manager-gui"/>$i<user username="testuser" password="password1" roles="fedoraUser"/>$i<user username="adminuser" password="password2" roles="fedoraUser"/>$i<user username="fedoraAdmin" password="secret3" roles="fedoraAdmin"/>$i<user username="fedora4" password="fedora4" roles="manager-gui"/>' /usr/local/tomcat/conf/tomcat-users.xml

RUN echo 'JAVA_OPTS="$JAVA_OPTS -Dfcrepo.modeshape.configuration=classpath:/config/'$ModeshapeConfig'/repository.json '$JDBCConfig' -Dfcrepo.home=/mnt/ingest -Dfcrepo.audit.container=/audit"' > $CATALINA_HOME/bin/setenv.sh \
	&& chmod +x $CATALINA_HOME/bin/setenv.sh

RUN cd /tmp \
	&& curl -fSL https://github.com/fcrepo4-exts/fcrepo-webapp-plus/releases/download/fcrepo-webapp-plus-$FEDORA_TAG/fcrepo-webapp-plus-$FedoraConfig$FEDORA_VERSION.war -o fcrepo.war \
	&& cp fcrepo.war /usr/local/tomcat/webapps/fcrepo.war


# Install Solr
ENV SOLR_VERSION 7.5.0
ENV SOLR_HOME /usr/local/tomcat/solr

RUN cd /tmp \
	&& mkdir -p /var/lib/tomcat/fcrepo4-data \
	&& chmod g-w /var/lib/tomcat/fcrepo4-data \
	&& curl -fSL http://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz -o solr-$SOLR_VERSION.tgz \
	&& curl -fSL http://repo1.maven.org/maven2/commons-logging/commons-logging/1.1.2/commons-logging-1.1.2.jar -o commons-logging-1.1.2.jar \
	&& mkdir -p "$SOLR_HOME"

#RUN tar -xzf solr-"$SOLR_VERSION".tgz \
#	&& cp -v /tmp/solr-"$SOLR_VERSION"/dist/solr-"$SOLR_VERSION".war /usr/local/tomcat/webapps/solr.war \
#	&& cp "commons-logging-1.1.2.jar" /usr/local/tomcat/lib \
#	&& cp /tmp/solr-"$SOLR_VERSION"/example/lib/ext/slf4j* /usr/local/tomcat/lib \
#	&& cp /tmp/solr-"$SOLR_VERSION"/example/lib/ext/log4j* /usr/local/tomcat/lib \
#	&& cp -Rv /tmp/solr-"$SOLR_VERSION"/example/solr/* $SOLR_HOME \
#	&& touch /var/lib/tomcat/velocity.log

COPY config/schema.xml $SOLR_HOME/collection1/conf/


WORKDIR /usr/local/tomcat


EXPOSE 8080
EXPOSE 8090
