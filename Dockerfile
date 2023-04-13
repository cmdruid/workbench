FROM debian:bullseye-slim

## Define build arguments.
ARG HOMEPATH='/root/home'
ARG CONFPATH='/config'
ARG DATAPATH='/data'

## Define volumes.
VOLUME $CONFPATH
VOLUME $DATAPATH

## Install dependencies.
RUN apt-get update && apt-get install -y \
  build-essential pkg-config libssl-dev iproute2 curl \
  git jq lsof man neovim netcat procps qrencode tmux unzip

## Install Python
RUN apt-get install -y python3 python3-pip

## Install Node.
RUN curl -fsSL https://fnm.vercel.app/install | bash
RUN . /root/.bashrc && \
  LATEST=$(fnm list-remote | tail -n 1) \
  && fnm install $LATEST \
  && npm install -g npm yarn

## Install Rust.
## RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

## Install ngrok.
RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null 
RUN echo "deb https://ngrok-agent.s3.amazonaws.com bullseye main" | tee /etc/apt/sources.list.d/ngrok.list 
RUN apt update && apt install ngrok

## Copy over binaries.
COPY build/out /tmp/bin/

WORKDIR /tmp/bin

## Unpack and/or install binaries.
RUN for file in $(find -maxdepth 1); do \
  if [ -n "$(echo $file | grep .tar.)" ]; then \
    echo "Unpacking $file to /usr/local ..." \
    && tar --wildcards --strip-components=1 -C /usr/local -xf $file \
  ; else \
    echo "Moving $file to /usr/local/bin ..." \
    && chmod +x $file && mv $file /usr/local/bin \
  ; fi \
; done

## Clean up temporary files.
RUN rm -rf /tmp/* /var/tmp/*

## Uncomment this if you want to install additional packages.
#RUN apt-get install -y <packages>

## Uncomment this if you want to wipe all repository lists.
#RUN rm -rf /var/lib/apt/lists/*

## Copy over runtime.
COPY image /
COPY config $CONFPATH/
COPY home $HOMEPATH/

## Link entrypoint script to bin.
RUN mkdir -p /usr/bin
RUN ln -s $HOMEPATH/entrypoint.sh /usr/bin/entrypoint

## Add custom profile to bashrc.
RUN PROFILE="$HOMEPATH/.profile" \
  && printf "\n[ -f $PROFILE ] && . $PROFILE\n\n" >> /root/.bashrc

## Setup Environment.  
ENV LOGS='/var/log'
ENV DATA="$DATAPATH"
ENV CONF="$CONFPATH"
ENV PATH="$HOMEPATH/bin:/root/.local/bin:$PATH"
ENV HOMEPATH="$HOMEPATH"

## Configure user account.
WORKDIR /root/home

ENTRYPOINT [ "entrypoint" ]
