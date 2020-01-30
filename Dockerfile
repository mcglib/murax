FROM registry.it.mcgill.ca/lts/murax/base:latest
# Different layer for gems installation
ENV APP_PATH /storage/www/murax/current
ENV BACKUP_PATH /root/backup
ENV MODEL_PATH $BACKUP_PATH/models
ENV VENDOR_PATH /vendor
ENV BUNDLER_CACHE_PATH /vendor/cache
ENV STARTUP_PATH /docker
ENV GEM_HOME="/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH
ENV BUNDLE_PATH "/storage/www/murax/shared/bundle"
ENV BUNDLE_VERSION 2.1.4
ENV WAITFORIT_VERSION="v2.1.0"
ENV FITS_VERSION 1.0.5
ENV FITS_HOME /opt/$FITS_VERSION/install

WORKDIR $APP_PATH
ADD Gemfile $APP_PATH
ADD Gemfile.lock $APP_PATH

RUN curl -o /usr/local/bin/waitforit -sSL https://github.com/maxcnunes/waitforit/releases/download/$WAITFORIT_VERSION/waitforit-linux_amd64 && \
    chmod +x /usr/local/bin/waitforit

RUN eval "$(rbenv init -)"; gem install bundler -v $BUNDLE_VERSION -f \
 && bundle check || bundle install --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3 --path $BUNDLE_PATH \
 && rm -rf /tmp/*

# Install YARN
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get -qq update && apt-get -qq install yarn \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p $FITS_HOME \
 && cd $FITS_HOME \
 && wget  http://projects.iq.harvard.edu/files/fits/files/fits-$FITS_VERSION.zip \
 && unzip fits-$FITS_VERSION.zip \
 && chmod 755 $FITS_HOME/fits-$FITS_VERSION/fits.sh \
 && cp -r $FITS_HOME/fits-$FITS_VERSION /usr/local/lib \
 && ln -s $FITS_HOME/fits-$FITS_VERSION/fits.sh /usr/local/bin/fits.sh


COPY ./docker/services/hyrax/config/sidekiq_systemd.init /etc/init.d/sidekiq

RUN mkdir -p /storage/www/murax/public \
 && mkdir -p /storage/www/murax/releases \
 && mkdir -p /storage/www/tmp \
 && mkdir -p /storage/www/uploads \
 && mkdir -p /storage/www/derivatives \
 && mkdir -p /var/log/apache2/murax

# Setup apache + passenger
COPY ./docker/services/hyrax/config/apache_vhost.conf /etc/apache2/sites-available/000-default.conf 
COPY ./docker/services/hyrax/config/apache_sslredirect_vhost.conf /etc/apache2/sites-enabled/redirect.conf

# Setup the apache ssl
COPY ./docker/services/hyrax/config/cert.crt /etc/ssl/private/cert.crt
COPY ./docker/services/hyrax/config/cert.key /etc/ssl/private/cert.key
COPY ./docker/services/hyrax/config/DigiCertCA.crt /etc/ssl/private/DigiCertCA.crt
COPY ./docker/services/hyrax/startup.sh $STARTUP_PATH/startup.sh

# Create the log file to be able to run tail
RUN touch /var/log/cron.log \
 && mkdir -p $APP_PATH/log \
 && touch $APP_PATH/log/sidekiq.log \
 && mkdir -p $STARTUP_PATH \
 && chmod 0644 $STARTUP_PATH/startup.sh

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80
EXPOSE 443
EXPOSE 3000

WORKDIR $APP_PATH

ENTRYPOINT ["/bin/bash", "/docker-entrypoint.sh"]
CMD ["/bin/bash", "/docker/startup.sh"]
