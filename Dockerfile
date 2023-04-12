FROM debian:bullseye-slim

## Define build arguments.
ARG ROOTHOME='/root/home'
ARG DATAPATH="/data"

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
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

## Install ngrok.
RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null 
RUN echo "deb https://ngrok-agent.s3.amazonaws.com bullseye main" | tee /etc/apt/sources.list.d/ngrok.list 
RUN apt update && apt install ngrok

## Copy over binaries.
COPY build/out /tmp/bin/

WORKDIR /tmp/bin

## Unpack and/or install binaries.
RUN for file in *; do \
  if [ -n "$(echo $file | grep .tar.)" ]; then \
    echo "Unpacking $file to /usr/local ..." \
    && tar --wildcards --strip-components=1 -C /usr/local -xf $file \
  ; else \
    echo "Moving $file to /usr/local/bin ..." \
    && chmod +x $file && mv $file /usr/local/bin \
  ; fi \
; done

RUN ls /usr

## Clean up temporary files.
RUN rm -rf /tmp/* /var/tmp/*

## Uncomment this if you want to install additional packages.
#RUN apt-get install -y <packages>

## Uncomment this if you want to wipe all repository lists.
#RUN rm -rf /var/lib/apt/lists/*

## Copy over runtime.
COPY image /
COPY config /config/
COPY home /root/home/

## Link entrypoint script to bin.
RUN mkdir -p /usr/bin
RUN ln -s $ROOTHOME/entrypoint.sh /usr/bin/entrypoint

## Add custom profile to bashrc.
RUN PROFILE="$ROOTHOME/.profile" \
  && printf "\n[ -f $PROFILE ] && . $PROFILE\n\n" >> /root/.bashrc

## Setup Environment.
ENV PATH="$ROOTHOME/bin:/root/.local/bin:$PATH"
ENV DATA="$DATAPATH"

WORKDIR /root/home

ENTRYPOINT [ "entrypoint" ]
