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
#ENV SOLR_VERSION 7.5.0
#ENV SOLR_HOME /opt

#RUN cd $SOLR_HOME \
#    && wget -q http://www-eu.apache.org/dist/lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz

#WORKDIR $SOLR_HOME
#RUN tar xzf solr-$SOLR_VERSION.tgz solr-$SOLR_VERSION/bin/install_solr_service.sh --strip-components=2

#RUN apt-get install -y procps

#RUN cd $SOLR_HOME \
#    && bash ./install_solr_service.sh solr-$SOLR_VERSION.tgz

#RUN service solr start \
#&&  su - solr -c "$SOLR_HOME/solr/bin/solr create -c collection1 -n collection1"

#COPY config/schema.xml $SOLR_HOME/solr/server/solr/configsets/_default/conf/


WORKDIR /usr/local/tomcat


EXPOSE 8080
EXPOSE 8090
