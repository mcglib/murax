FROM ubuntu:18.04
RUN apt-get update
RUN apt-get install locales

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV GEM_HOME="/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

# Install dependencies
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -qq wget unzip build-essential cmake gcc libcunit1-dev libudev-dev git redis-server curl \
&& apt-get install -qq libssl-dev libreadline-dev zlib1g-dev clamav  libclamav-dev openssl tzdata libpq-dev libsqlite3-dev libimage-exiftool-perl

# install libreoffice and imagemagick / nokogiri / vim
RUN apt-get -qq install libreoffice imagemagick ffmpeg libxml2-dev libxslt1-dev vim \
&&  apt-get -qq install ghostscript poppler-utils  nano lynx libsaxon-java unzip zlib1g-dev tcsh telnet

# Change default locale to en-US.UTF-8
ENV LANG=en_US.UTF-8
RUN localedef -f UTF-8 -i en_US en_US.UTF-8
RUN echo America/New_York >/etc/timezone
RUN ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata

# Install nodejs and npm
RUN curl --silent --location https://deb.nodesource.com/setup_6.x | bash - \
&& apt-get install -qq nodejs\
&& apt-get install -qq apt-transport-https build-essential cmake nodejs software-properties-common unzip g++

# install pip and some of the requirements for Clara's script
RUN apt-get install -y --no-install-recommends python-pip \
# Install pip packages
&& pip install requests


# Install yarn
RUN wget -q -O - https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
RUN apt-get install -y yarn


#COPY --from=build $RBENV_ROOT $RBENV_ROOT

# Installm libcurl
RUN  apt-get -qq install libcurl4 libcurl4-openssl-dev ruby-curb

# install pip and some of the requirements for Clara's script
RUN apt-get install -y --no-install-recommends python-pip \
# Install pip packages
&& pip install requests

# Install Passenger and apache
RUN  apt-get install -qq dirmngr gnupg \
&& apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 \
&& apt-get install -qq apt-transport-https ca-certificates


RUN sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger bionic main > /etc/apt/sources.list.d/passenger.list' \
&&  apt-get update \
&&  apt-get install -qq libapache2-mod-passenger apache2

# Enabled passenger and restart apache
RUN a2enmod passenger \
&& apachectl restart

# Bundle installs with binstubs to our custom /bundle/bin volume path. Let system use those stubs.
RUN a2enmod ssl



# Install rbenv
ENV PATH /usr/local/rbenv/bin:$PATH
ENV RBENV_ROOT /usr/local/rbenv
ENV CONFIGURE_OPTS --disable-install-doc
ENV PATH /usr/local/rbenv/bin:/usr/local/rbenv/shims:$PATH

RUN git clone git://github.com/rbenv/rbenv.git /usr/local/rbenv \
&& git clone git://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build \
&& git clone git://github.com/jf/rbenv-gemset.git /usr/local/rbenv/plugins/rbenv-gemset \
&& /usr/local/rbenv/plugins/ruby-build/install.sh
RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh \
&& echo 'export PATH=/usr/local/rbenv/bin:$PATH' >> /etc/profile.d/rbenv.sh \
&& echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /root/.bashrc \
&& echo 'export PATH=/usr/local/rbenv/bin:$PATH' >> /root/.bashrc \
&& echo 'eval "$(rbenv init -)"' >> /root/.bashrc


# Install ruby versio $RUBY_VERSION
ENV RUBY_VERSION 2.5.3
RUN eval "$(rbenv init -)"; rbenv install $RUBY_VERSION \
&& eval "$(rbenv init -)"; rbenv global $RUBY_VERSION \
&& eval "$(rbenv init -)"; gem update --system

# install Gems that we need globally and not per app
RUN gem install capistrano \
 curb \
 rake \
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
 whenever
