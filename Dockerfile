FROM archlinux:base

ENV HOME=/
ENV TMPDIR=/tmp
ENV TZ=Etc/GMT
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN pacman -Syuu --noconfirm \
  && pacman -S --noconfirm \
  dnsutils \
  python3 python-pip \
  git \
  jq \
  openssl \
  mariadb-clients \
  net-tools \
  netcat \
  nmap \
  postgresql-libs \
  tree \
  vim \
  wget \
  unzip \
  && pacman -Scc --noconfirm

# Install pip modules
RUN pip3 install kubernetes pycodestyle pylint yamllint awscli reckoner

RUN useradd -m -s /bin/bash -b /home asdf

ENV HOME=/home/asdf
ENV PATH="${PATH}:${HOME}/.asdf/shims:${HOME}/.asdf/bin"

USER asdf
RUN git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf && \
  cd $HOME/.asdf && \
  git checkout "$(git describe --abbrev=0 --tags)" && \
  echo '. $HOME/.asdf/asdf.sh' >> $HOME/.bashrc && \
  echo '. $HOME/.asdf/asdf.sh' >> $HOME/.profile

ADD .asdfrc  $HOME/.asdfrc
ADD tool-versions $HOME/.tool-versions
RUN cd /tmp && for p in $(cat $HOME/.tool-versions | awk '{print $1}') ; do asdf plugin add $p; asdf install $p; done
RUN rm -rf /tmp/*
