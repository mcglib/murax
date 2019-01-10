FROM ubuntu:16.04
RUN apt-get update
RUN apt-get install locales

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV INSTALL_PATH /usr/src/app
ENV BACKUP_PATH /root/backup
ENV MODEL_PATH $BACKUP_PATH/models
ENV VENDOR_PATH /vendor

# Install dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -qq wget unzip build-essential cmake gcc libcunit1-dev libudev-dev git redis-server curl \
&& apt-get install -qq libssl-dev libreadline-dev zlib1g-dev clamav  libclamav-dev openssl tzdata libcurl4-openssl-dev libpq-dev libsqlite3-dev

# Install nodejs and npm
RUN curl --silent --location https://deb.nodesource.com/setup_6.x | bash - \
&& apt-get install -qq nodejs

# Install Passenger and apache
RUN  apt-get install -qq dirmngr gnupg \
&& apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 \
&& apt-get install -qq apt-transport-https ca-certificates


RUN sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main > /etc/apt/sources.list.d/passenger.list' \
&&  apt-get update \
&&  apt-get install -qq libapache2-mod-passenger apache2

# Enabled passenger and restart apache
RUN a2enmod passenger \
&& apachectl restart





# Change default locale to en-US.UTF-8
ENV LANG=en_US.UTF-8
RUN localedef -f UTF-8 -i en_US en_US.UTF-8
RUN echo America/New_York >/etc/timezone
RUN ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata

RUN git clone git://github.com/rbenv/rbenv.git /usr/local/rbenv \
&& git clone git://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build \
&& git clone git://github.com/jf/rbenv-gemset.git /usr/local/rbenv/plugins/rbenv-gemset \
&& /usr/local/rbenv/plugins/ruby-build/install.sh
ENV PATH /usr/local/rbenv/bin:$PATH
ENV RBENV_ROOT /usr/local/rbenv

RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh \
&& echo 'export PATH=/usr/local/rbenv/bin:$PATH' >> /etc/profile.d/rbenv.sh \
&& echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /root/.bashrc \
&& echo 'export PATH=/usr/local/rbenv/bin:$PATH' >> /root/.bashrc \
&& echo 'eval "$(rbenv init -)"' >> /root/.bashrc

ENV CONFIGURE_OPTS --disable-install-doc
ENV PATH /usr/local/rbenv/bin:/usr/local/rbenv/shims:$PATH

ENV RBENV_VERSION 2.5.3
RUN eval "$(rbenv init -)"; rbenv install $RBENV_VERSION \
&& eval "$(rbenv init -)"; rbenv global $RBENV_VERSION \
&& eval "$(rbenv init -)"; gem update --system \
&& eval "$(rbenv init -)"; gem install bundler -f \
&& rm -rf /tmp/*

ENV RBENV_ROOT /usr/local/rbenv
RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /root/.bashrc \
&& echo 'eval "$(rbenv init -)"' >> /root/.bashrc
#COPY --from=build $RBENV_ROOT $RBENV_ROOT



# install libreoffice and imagemagick
RUN apt-get -qq install libreoffice imagemagick ffmpeg

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for capybara-webkit
#RUN apt-get install -y libqt4-webkit libqt4-dev xvfb




# Install YARN
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
&& echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
&& apt-get -qq update && apt-get -qq install yarn

# Install fits
ENV FITS_VERSION 1.0.5
ENV FITS_HOME /opt/$FITS_VERSION/install

RUN apt-get -qq install ghostscript poppler-utils  nano lynx libsaxon-java unzip zlib1g-dev tcsh telnet

RUN mkdir -p $FITS_HOME

RUN cd $FITS_HOME \
 && wget  http://projects.iq.harvard.edu/files/fits/files/fits-$FITS_VERSION.zip \
 && unzip fits-$FITS_VERSION.zip
RUN cd $FITS_HOME \
 && chmod 755 $FITS_HOME/fits-$FITS_VERSION/fits.sh \ 
 && cp -r $FITS_HOME/fits-$FITS_VERSION /usr/local/lib \
 && ln -s $FITS_HOME/fits-$FITS_VERSION/fits.sh /usr/local/bin/fits.sh


# Different layer for gems installation
ENV APP_PATH /usr/src/app
WORKDIR $APP_PATH
ADD Gemfile $APP_PATH
ADD Gemfile.lock $APP_PATH

# install global gems
RUN echo $'gem install capistrano \
 therubyracer \
 rails-html-sanitizer \
 mini_portile2 \
 crass \
 rails-dom-testing \
 builder \
 erubi \
 thor \
 method_source \
 i18n \
 concurrent-ruby \
 tzinfo \
 thread_safe \
 rack \
 i18n \
 concurrent-ruby \
 tzinfo \
 thread_safe \
 rack \
 rack-test \
 loofah \
 nokogiri \
 nio4r \
 websocket-extensions \
 globalid \
 mini_mime \
 mail \
 sprockets \
 sprockets-rails \
 redis \
 connection_pool \
 rack-protection \
 whenever' \
 >> /etc/example.conf


#RUN bundle update && bundle install --retry 5
ENV GEM_HOME="/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH
ENV BUNDLE_PATH "/storage/www/murax/shared/bundle"
RUN bundle check || bundle install --binstubs="$BUNDLE_BIN" --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3

# # Start various services
ENV WAITFORIT_VERSION="v2.1.0"
RUN curl -o /usr/local/bin/waitforit -sSL https://github.com/maxcnunes/waitforit/releases/download/$WAITFORIT_VERSION/waitforit-linux_amd64 && \
    chmod +x /usr/local/bin/waitforit


COPY ./docker/services/hyrax/config/sidekiq_systemd.init /etc/init.d/sidekiq

# Bundle installs with binstubs to our custom /bundle/bin volume path. Let system use those stubs.

RUN a2enmod ssl
RUN mkdir -p /storage/www/murax/public
RUN mkdir -p /storage/www/murax/releases
RUN mkdir -p /storage/www/tmp
RUN mkdir -p /storage/www/uploads
RUN mkdir -p /var/log/apache2/murax

# Setup apache + passenger
COPY ./docker/services/hyrax/config/apache_vhost.conf /etc/apache2/sites-available/000-default.conf
COPY ./docker/services/hyrax/config/apache_sslredirect_vhost.conf /etc/apache2/sites-enabled/redirect.conf

# Setup the apache ssl
COPY ./docker/services/hyrax/config/cert.crt /etc/ssl/private/cert.crt
COPY ./docker/services/hyrax/config/cert.key /etc/ssl/private/cert.key
COPY ./docker/services/hyrax/config/DigiCertCA.crt /etc/ssl/private/DigiCertCA.crt

WORKDIR $APP_PATH


# Create the log file to be able to run tail
RUN touch /var/log/cron.log

ENV STARTUP_PATH /docker
RUN mkdir -p $STARTUP_PATH
COPY ./docker/services/hyrax/startup.sh $STARTUP_PATH/startup.sh
RUN chmod 0644 $STARTUP_PATH/startup.sh


EXPOSE 80
EXPOSE 443
EXPOSE 3000


COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh


ENTRYPOINT ["/docker-entrypoint.sh"]
