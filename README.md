# Workbench

A docker workbench container, pre-configured with environments for NodeJs, Python and Rust.

## Overview

Here is an overview of the project filesystem:

```sh
## Project Directory
/config      # Mounted as read-only at /config.
             # Useful for collecting our config files in 
             # one place, so we can tweak them between builds.

/home        # Mounted as read-write at /root/home.
             # Scripts placed in 'bin' are added to your PATH 
             # environment. The .bashrc script is loaded at login.

/image       # Copied to root filesystem '/' at build time.
             # Create your desired filesystem in here, using the 
             # proper paths. (for ex. binaries in /image/usr/bin/')

.env.sample  # Example of .env file. Used for setting variables that
             # are passed into the build and runtime environments.

compose.yml  # Container configuration file. Launch your container in 
             # detached mode by using: 'docker compose up --build -d'

Dockerfile   # Main build file for the docker container. Feel free to 
             # configure this file to your liking!

README.md    # You are here!
```

**Tips**  

- The `Dockerfile` specifies what packages are installed by default. Modify the `apt install` line to add more packages to your container.
- The `home` folder is reloaded upon login, so you can make changes to your environment frequenlty!
- Use the `home/bin` folder to store your own custom scripts (and call them directly).
- Use the `.init` and `.profile` scripts to customize your own shell environment.
- Feel free to `--build` frequently as you make changes to the filesystem.

## How to Use
```sh
## Build the image and start in a container.
docker compose up --build

## Start the container in detached mode.
docker compose up -d

## You can also do all of this in one line.
docker compose up --build -d

## Log into a currently running container.
docker exec -it <container name> bash

## If you have any issues with starting your container,
## log into the container's shell, then start the script.
docker compose run -it --entrypoint bash <container name>
<~/home> entrypoint
```

### Ngrok Integration

Setting `NGROK_ENABLED=1` in your `.env` file will enable Ngrok integration. This will configure your container to setup an encrypted Ngrok tunnel. You will have to sign up [here](https://ngrok.com) in order to receive an `NGROK_TOKEN` and use their service.

### Tor Integration

Setting `TOR_ENABLED=1` in your `.env` file will enable Tor integration. This will configure your container to setup a Tor Hidden Services node. You will have to configure a `torrc` file and place it in `/config`. Also, make sure your hidden services are stored in `/data` for persistence.

## Resources

For more information and resources, please see the links below.

**Docker Compose Reference**  
https://docs.docker.com/compose/compose-file

**Docker Builder Reference**  
https://docs.docker.com/engine/reference/builder

**Docker Exec Reference**  
https://docs.docker.com/engine/reference/commandline/exec
