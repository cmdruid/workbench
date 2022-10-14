FROM debian:bullseye-slim

ARG HOMEDIR="/root"
ARG RUNPATH="$HOMEDIR/run"
ARG LIBPATH="$RUNPATH/lib"

## Install base dependencies.
RUN apt-get update && apt-get install -y \
  curl git iproute2 jq lsof man netcat \
  openssl procps qrencode socat xxd neovim

## Install optional dependencies.
#

## Install Python.
RUN apt-get install -y python3 python3-pip

## Install python packages.
RUN pip3 install Flask pyln-client

## Install Node.
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs

## Install node packages.
#RUN npm install -g npm yarn clightningjs

## Copy over binaries.
COPY build/out/* /tmp/bin/

WORKDIR /tmp

## Unpack and/or install binaries.
RUN for file in /tmp/bin/*; do \
  if ! [ -z "$(echo $file | grep .tar.)" ]; then \
    echo "Unpacking $file to /usr ..." \
    && tar --wildcards --strip-components=1 -C /usr -xf $file \
  ; else \
    echo "Moving $file to /usr/local/bin ..." \
    && chmod +x $file && mv $file /usr/local/bin/ \
  ; fi \
; done

## Clean up temporary files.
RUN rm -rf /tmp/* /var/tmp/*

## Uncomment this if you also want to wipe all repository lists.
#RUN rm -rf /var/lib/apt/lists/*

## Copy configuration and run environment.
COPY config /
COPY run $RUNPATH/

## Add bash aliases to .bashrc.
RUN alias_file="~/.bash_aliases" \
  && printf "if [ -e $alias_file ]; then . $alias_file; fi\n\n" >> $HOMEDIR/.bashrc

## Make sure scripts are executable.
RUN for file in `grep -lr '#!/usr/bin/env' $RUNPATH`; do chmod +x $file; done

## Symlink entrypoint to /usr/local/bin.
RUN ln -s $RUNPATH/entrypoint.sh /usr/local/bin/workbench

## Configure run-time environment.
ENV PATH="$RUNPATH/bin:$HOMEDIR/.local/bin:$PATH"
ENV PYPATH="$RUNPATH/pylib:$PYPATH"
ENV NODE_PATH="$RUNPATH/nodelib:$NODE_PATH"
ENV RUNPATH="$RUNPATH"
ENV LIBPATH="$LIBPATH"
ENV LOGPATH="/var/log"

WORKDIR $HOMEDIR

ENTRYPOINT [ "workbench" ]
CMD [ "start" ]
