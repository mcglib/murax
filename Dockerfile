FROM centos:centos7
LABEL maintainer "Library AppDev"
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG arch=arm64

ENV APP_PATH /storage/www/murax/current
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
	cmake \
	apache2 \
	ca-certificates \
	sqlite-devel && \
	yum clean all

RUN yum -y install ImageMagick

RUN rm -f /etc/ssl/certs/ca-bundle.crt && yum reinstall -y ca-certificates

# Install via rbenv (ruby 2.6.8)
# Install rbenv
ENV PATH /usr/local/rbenv/bin:$PATH
ENV RBENV_ROOT /usr/local/rbenv
ENV CONFIGURE_OPTS --disable-install-doc
ENV PATH /usr/local/rbenv/bin:/usr/local/rbenv/shims:$PATH

RUN git clone git://github.com/rbenv/rbenv.git /usr/local/rbenv \
 && git clone git://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build \
 && git clone git://github.com/jf/rbenv-gemset.git /usr/local/rbenv/plugins/rbenv-gemset \
 && /usr/local/rbenv/plugins/ruby-build/install.sh \
 && echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh \
 && echo 'export PATH=/usr/local/rbenv/bin:$PATH' >> /etc/profile.d/rbenv.sh \
 && echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /root/.bashrc \
 && echo 'export PATH=/usr/local/rbenv/bin:$PATH' >> /root/.bashrc \
 && echo 'eval "$(rbenv init -)"' >> /root/.bashrc

RUN rbenv install $RUBY_VERSION
RUN rbenv global $RUBY_VERSION
#RUN curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-doctor | bash 

RUN gem update --system
RUN gem install bundler -v $BUNDLE_VERSION -f \
 	&& gem install --default bundler -v $BUNDLE_VERSION -f \
 	&& gem install whenever
ENV GROUP_ID 9999
ENV USER_ID 126895
RUN groupadd -g $GROUP_ID muraxuser
RUN adduser --gid $GROUP_ID muraxuser
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo 'muraxuser:muraxuser' | chpasswd
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR $APP_PATH
 ADD Gemfile $APP_PATH
 ADD Gemfile.lock $APP_PATH
 #COPY --chown=muraxuser:muraxuser . $APP_PATH
 # save time-stamp in a file on docker build
 ONBUILD RUN echo $(/bin/date "+%Y-%m-%d %H:%M:%S" && echo "google: " && curl -s --head http://google.com | grep ^Date: | sed 's/Date: //g') >  $APP_PATH/public/build_timestamp.txt
# #
# # # set permissions
 ONBUILD RUN chown --recursive muraxuser log tmp public

 RUN  mkdir -p $BUNDLE_PATH \
 	&&  mkdir -p $BUNDLER_CACHE_PATH \
 	&&  chown muraxuser:muraxuser -R $BUNDLE_PATH \
 	&&  chown muraxuser:muraxuser -R $BUNDLER_CACHE_PATH
 USER root

 RUN bundle check || bundle install --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3 --path $BUNDLE_PATH

RUN curl --silent --location https://rpm.nodesource.com/setup_14.x | bash - && \
	yum install -y nodejs

 RUN curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo && \
 	yum -y install yarn

COPY ./docker/services/hyrax/config/apache_vhost.conf /etc/httpd/vhosts/000-default.conf 
COPY ./docker/services/hyrax/config/apache_sslredirect_vhost.conf /etc/httpd/vhosts/redirect.conf

# # Setup the apache ssl
COPY ./docker/services/hyrax/config/cert.crt /etc/ssl/pki/private/cert.crt
COPY ./docker/services/hyrax/config/cert.key /etc/ssl/pki/private/cert.key

#COPY ./docker/services/hyrax/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy.xml

COPY . $APP_PATH
ENV STARTUP_PATH /docker
COPY ./docker/services/hyrax/startup.sh $STARTUP_PATH/startup.sh

EXPOSE 80
EXPOSE 443
EXPOSE 3000

WORKDIR $APP_PATH

CMD ["/bin/bash", "/docker/startup.sh"]
#ENTRYPOINT ["/bin/bash", "-l", "-c"]