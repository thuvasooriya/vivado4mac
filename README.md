# vivado4mac

![vivado running on mac](https://i.imgur.com/6d9ymRX.png)

this is a tool for installing [Xilinx Vivado™](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools.html) on arm-based apple silicon macs (tested on m3 macbook pro with 2023.1 edition of vivado). it is in no way associated with xilinx.

this repo is a fork of that tool focused on optimizing the workflow using orbstack as the docker client and optimizations for other footguns

## roadmap

- [x] vivado 2023.1 setup for orbstack
- [ ] automatic xquartz configuration setup
- [ ] automate email password of installation procedure
- [ ] download resume support
- [ ] build out a more efficient docker container and host it on dockerhub

- [ ] xquartz optimization for docker
- [ ] add support for mac file sync using orbstack
- [ ] customize downloads and resume support
- [ ] add support for other versions of vivado
- [ ] explore efficient use of docker container using nix tools

## feature map
need to test whats working and what's not
- [x] synthesis
- [x] implementation
- [ ] route and place

## how to install

expect the installation process to last about one to two hours and download ~20 gb.

### prerequisites

1. you'll need docker installed with a compatible docker client. this tool uses orbstack as the docker client. You can install orbstack using homebrew or nix or whatever method you prefer.
2. you'll need to install [xquartz](https://www.xquartz.org/). you can install xquartz using homebrew or nix or whatever method you prefer.

- if you are using [docker desktop](https://www.docker.com/products/docker-desktop/) better to follow the original repo instructions.

3. configure docker

- enable rosetta and increase the memory slider in orbstack

if using docker desktop

- go to settings,
- check "Use Virtualization Framework",
- uncheck "Open Docker Dashboard at startup",
- go to "Resources"
- increase Swap to 2GB (if synthesis fails, you may need to increase Memory or Swap)
- go to "Features in Development" and
- check "Use Rosetta for x86/amd64 emulation on Apple Silicon".

additionally make sure to download the _linux self extracting web installer_ from the [xilinx website](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools.html).

> only 2023.1 is supported for now
> note down the email and password you use for authentication during installation
> go to xquatrz configuration > security tab > make sure both are ticked

### installation

1. clone this repo or download the source code
2. extract the zip by double-clicking it.
3. navigate to the extracted folder in terminal and run the installer

```sh
cd Downloads/vivado4mac
caffeinate -dim ./install.sh
```

3. follow the instructions (in yellow) from the terminal. if a window pops up, close it.
4. Open the Vivado app. It will fail to launch, which is why you need to open Settings and trust the app in the "Privacy & Security" section.
5. open it again and go to settings again and trust xvcd.
6. close vivado.
7. drag and drop the "Vivado" app into the applications folder.

### usage

To start Vivado, simply open the Vivado app. It might take a while for the Docker container to start in the background and for Vivado to launch. Additionally, a terminal window will launch. It runs the XVC server as described below and is necessary for programming the FPGAs and closes when Vivado is closed.

If you want to exchange files with the Vivado instance, you need to store them inside the "vivado-on-silicon-mac-main" folder. Inside Vivado, the files will be accessible via the "/home/user" folder.

Clipboard copy & paste works with Ctrl-C and Ctrl-V.

You can allocate more/less memory and CPU resources to Vivado by going to the Resources tab in the Docker settings.

## How it works

### Docker & XQuartz

This script creates an x64 Docker container running Linux® that is accelerated by [Rosetta 2](https://developer.apple.com/documentation/apple-silicon/about-the-rosetta-translation-environment) via the Apple Virtualization framework. The container has all the necessary libraries preinstalled for running Vivado. It is installed automatically given an installer file that the user must provide. GUI functionality is provided by XQuartz.

### USB connection

A drawback of the Apple Virtualization framework is that there is no implementation for USB forwarding as of when I'm writing this. Therefore, these scripts set up the [Xilinx Virtual Cable protocol](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/644579329/Xilinx+Virtual+Cable). Intended to let a computer connect to an FPGA plugged into a remote computer, it allows for the host system to run an XVC server (in this case a software called [xvcd](https://github.com/tmbinc/xvcd) by Felix Domke), to which the docker container can connect.

xvcd is contained in this repository, but with slight changes to make it compile on modern day macOS (compilation requires libusb and libftdi installed via homebrew, though there is a compiled version included). It runs continuously while the docker container is running.

This version of xvcd only supports the FT2232C chip. There are forks of this software supporting other boards such as [xvcserver by Xilinx](https://github.com/Xilinx/XilinxVirtualCable).

### Environment variables

A few environment variables are set such that

1. the GUI is displayed correctly.
2. Vivado doesn't crash (maybe due to emulation?)

## License, copyright and trademark information

The repository's contents are licensed under the Creative Commons Zero v1.0 Universal license.

Note that the scripts are configured such that you automatically agree to Xilinx' and 3rd party EULAs (which can be obtained by extracting the installer yourself) by running them. You also automatically agree to [Apple's software licence agreement](https://www.apple.com/legal/sla/) for Rosetta 2.

This repository contains the modified source code of [xvcd](https://github.com/tmbinc/xvcd) as well as a compiled version which is statically linked against [libusb](https://libusb.info/) and [libftdi](https://www.intra2net.com/en/developer/libftdi/). This is in accordance to the [LGPL Version 2.1](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html), under which both of those libraries are licensed.

Vivado and Xilinx are trademarks of Xilinx, Inc.

Arm is a registered trademark of Arm Limited (or its subsidiaries) in the US and/or elsewhere.

Apple, Mac, MacBook, MacBook Air, macOS and Rosetta are trademarks of Apple Inc., registered in the U.S. and other countries and regions.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein.

Intel and the Intel logo are trademarks of Intel Corporation or its subsidiaries.

Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

Oracle, Java, MySQL, and NetSuite are registered trademarks of Oracle and/or its affiliates. Other names may be trademarks of their respective owners.

X Window System is a trademark of the Massachusetts Institute of Technology.
