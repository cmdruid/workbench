# workbench
A simple framework for developing multi-process (compose-free) technology stacks into a single docker image.

## How to Use

> *Note: Make sure that docker is installed, and your user is part of the docker group.*

To spin up a development environment:

```shell
## Clone this repository, and make it your working directory.

git clone "https://github.com/cmdruid/workbench.git"
cd workbench

## Build all source libraries listed in the build/dockerfile folder.
./workbench.sh build

## Launch a workbench container called "main".
./workbench.sh start main

## Launch a workbench container and run a specific script.
## (the default script is "start")
./workbench start main --script test

## A detailed guide is built into the help screen.
./workbench.sh --help
```
The `start` keyword designates your node with a name tag.

The default dockerfile ships with Flask and Nodejs included, plus a small library of development tools.

## Repository Overview

### \#\# ./build

This path contains the build script, related dockerfiles, and compiled binaries. When you run the `workbench.sh` script, it will fist scan the `build/dockerfiles` and `build/out` path in order to compare files. If a binary appears to be missing, the start script will then call the build script (with the related dockerfile), and request to build the missing binary from source. Compiled binaries are then copied `build/out`.

If you have just cloned this repositry, it's best to run `./workbench.sh build` as a first step, so that launching your first node doesn't force you to compile everything at once.

All files located in `build/out` are copied over to the main docker image and installed at build time, so feel free to include any binaries you wish! The script recognizes tar.gz compression, and will strip the first folder before unpacking into `/usr`, so make sure to pack your files accordingly.

You can also add your own `build/dockerfiles`, or modify the existing ones in order to try different builds and versions. If you add a custom dockerfile, make sure it also names the binary with a matching substring, so the start script can correctly determine if your binary is present / missing.

### \#\# ./config

These are the configuration files used by the main services in the stack. The entire config folder is copied at build time, and copied to the root of the container filesystem. Feel free to modify these files or add your own, then use commands `build` or `rebuild` to refresh the image.

The `.bash_aliases` file is also loaded upon startup, feel free to use it to customize your environment!

### \#\# ./run

This folder contains the main `entrypoint.sh` script, libraries and tools, plus all other scripts used to manage services in the stack.

- Files in `bin` are available in the container's PATH.
- Files in `lib\pylib` are available in the container's PYPATH.
- Files in `lib\nodelib` are available in the container's NODEPATH.
- Scripts in `startup` are callable by the --script option. By default the `start` script is called.

The entire run folder is copied at build time, located at `/root/run` in the image. Feel free to modify these files or add your own, then use `--build` or `--rebuild` flags to refresh the image when restarting a node. When a node is started in `--devmode`, the `run` folder is mounted directly, and you can modify the source files in real-time.

## Development

*Work in progress. Feel free to hack the project on your own!*

There are two modes to choose from when launching a container: **safe mode** and **development mode**.

By default, a node will launch in safe mode. A copy of the `/run` folder is made at build time, and code changes to `/run` will not affect the node (unless you rebuild and re-launch). The node will continue to run in the background once you exit the node terminal. The node is also configured to self-restart in the event of a crash.

When launching a node with `--devmode` enabled, a few things change. The `entrypoint.sh` script will not start automatically; you will have to call it yourself. The `/run` folder will be mounted directly into the container, so you can modify the source code in real-time.

Any changes to the source code will apply to *all* nodes. Re-run the start script to apply changes. When you exit the terminal, the container will be instantly destroyed, however the internal `/data` store will persist.

If you end up borking a node, use the `--wipe` flag at launch to erase the node's persistent storage. The start scripts are designed to be robust, and nodes are highly disposable. Feel free to crash, wipe, and re-launch nodes as often as you like!

You can monitor nodes through a management service like **portainer**, or simply login to the node using `./workbench.sh login *nametag*`.

To mount folders into a node's environment, use the format `--mount local/path:/mount/path` for each folder you wish to mount. Paths can be relative or absolute.

To open and forward ports from a node's environment, use the format `--ports int1:ext1,int2:ext2, ...`, with a comma to separate port declarations, and colon to separate internal:external ports.

The `--passthru` flag will allow you to pass a quoted string of flags directly to the internal `docker run` script. With great power comes great responsibility! :-)

## Contribution

All suggestions and contributions are welcome! If you have any questions about this project, feel free to submit an issue up above, or contact me on social media.

## Resources

**Python Documentation**  
Official resource for the python language.  
https://docs.python.org/3

**Flask Documentation**  
The go-to resource for documentation on using Flask.  
https://flask.palletsprojects.com/en/2.1.x

**Node.js Documentation**  
The go-to resource for documentation on using Nodejs.  
https://nodejs.org/api
