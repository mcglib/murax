FROM centos:centos7
LABEL maintainer "Library AppDev"
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG arch=arm64

ENV APP_PATH /usr/src/app
ENV BUNDLE_PATH /vendor/bundle
ENV BUNDLER_CACHE_PATH /vendor/cache
ENV BUNDLE_VERSION 2.1.4
ENV LANG=en_CA.UTF-8
ENV RUBY_VERSION 2.6.8
ENV PATH /usr/local/rbenv/bin:$PATH
ENV RBENV_ROOT /usr/local/rbenv
ENV CONFIGURE_OPTS --disable-install-doc
ENV PATH /usr/local/rbenv/bin:/usr/local/rbenv/shims:$PATH

ENV FITS_VERSION 1.0.5
ENV FITS_HOME /opt/$FITS_VERSION/install
ENV RUBY_VERSION 2.6.8

WORKDIR $APP_PATH
ADD Gemfile $APP_PATH
ADD Gemfile.lock $APP_PATH

# Install packages
RUN yum -y  groupinstall "Development Tools" && \
	yum -y install \
	gcc \
	nodejs \
	yarn  \
	wget \
	mysql \
	redis \
	curl \
	readline-devel \
	libffi-devel \
	libxslt-devel \
	zlib-devel \
	openssl-devel \
	mysql-devel \
	postgresql-libs \ 
	postgresql-devel \ 
	ffmpeg \ 
	unzip \ 
	ghostscript \ 
	gnupg \ 
	vim \
	apache2 \
	ca-certificates \
	sqlite-devel && \
	yum clean all

RUN yum -y install ImageMagick

RUN rm -f /etc/ssl/certs/ca-bundle.crt && yum reinstall -y ca-certificates


RUN curl -o /usr/local/bin/waitforit -sSL https://github.com/maxcnunes/waitforit/releases/download/$WAITFORIT_VERSION/waitforit-linux_amd64 && \
    chmod +x /usr/local/bin/waitforit

EXPOSE 80
EXPOSE 443
EXPOSE 3000

WORKDIR $APP_PATH

ENTRYPOINT ["/bin/bash", "/docker-entrypoint.sh"]
CMD ["/bin/bash", "/docker/startup.sh"]
