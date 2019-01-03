FROM ubuntu:16.04
RUN apt-get update
RUN apt-get install locales

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -qq wget unzip build-essential cmake gcc libcunit1-dev libudev-dev git redis-server curl \
&& apt-get install -qq libssl-dev libreadline-dev zlib1g-dev

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

COPY --from=build $RBENV_ROOT $RBENV_ROOT
ENV PATH /usr/local/rbenv/bin:/usr/local/rbenv/shims:$PATH

RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /root/.bashrc \
&& echo 'eval "$(rbenv init -)"' >> /root/.bashrc \
