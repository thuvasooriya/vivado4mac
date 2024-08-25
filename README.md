# vivado-on-silicon-mac

this is a tool for installing [vivado™](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadnav/vivado-design-tools.html) on arm®-based apple silicon macs in a rosett-enabled virtual machine. it is in no way associated with xilinx or amd.

### preparations

install orbstack (because miles better than docker desktop)
prepare your email and password credentials for amd beforehand
you will also need the vivado installer file (the "linux® self extracting web installer").

### installation

```
cd Downloads/vivado-on-silicon-mac-main
caffeinate -dim zsh ./scripts/setup.sh
```

### usage

```
Downloads/vivado-on-silicon-mac-main/scripts/start_container.sh
```

inside the terminal. The container can be stopped by pressing `Ctrl-C` inside the terminal or by logging out inside the container.

### troubleshooting

if the installation fails or vivado crashes, consider:

- deleting the folder and go through the above steps again
- establishing a more reliable internet connection
- trying a different version of vivado
- increasing ram / swap / cpu allocations in the docker settings.

## installing other software

If you want to use additional Ubuntu packages, specify them in the Dockerfile. If you want to install further AMD / Xilinx software, you can do so by copying the corresponding installer into the folder containing the Vivado installation and launching it via the GUI. **Attention!** You must install it into the folder `/home/user/Xilinx` because any data outside of `/home/user` does not persist between VM reboots. You can even skip installing Vivado entirely by commenting out the last line of `setup.sh`. I do not plan on supporting this out of the box.

## how it works

### docker, rosetta & vnc

This collection of scripts creates an x64 Docker container running Linux® that is accelerated by [Rosetta 2](https://developer.apple.com/documentation/apple-silicon/about-the-rosetta-translation-environment) via the Apple Virtualization framework. The container has all the necessary libraries preinstalled for running Vivado. It is installed automatically given an installer file that the user must provide. GUI functionality is provided via VNC and the built-in "Screen Sharing" app.

### usb connection

A drawback of the Apple Virtualization framework is that there is no implementation for USB forwarding as of when I'm writing this. Therefore, these scripts set up the [Xilinx Virtual Cable protocol](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/644579329/Xilinx+Virtual+Cable). Intended to let a computer connect to an FPGA plugged into a remote computer, it allows for the host system to run an XVC server (in this case a software called [xvcd](https://github.com/tmbinc/xvcd) by Felix Domke), to which the docker container can connect.

xvcd is contained in this repository, but with slight changes to make it compile on modern day macOS (compilation requires libusb and libftdi installed via homebrew, though there is a compiled version included). It runs continuously while the docker container is running.

This version of xvcd only supports the FT2232C chip. There are forks of this software supporting other boards such as [xvcserver by Xilinx](https://github.com/Xilinx/XilinxVirtualCable).

## files overview

- `xvcd`: [xvcd](https://github.com/tmbinc/xvcd) source and binary copy

## license, copyright and trademark information

the repository's contents are licensed under the creative commons zero v1.0 universal license.

note that the scripts are configured such that you automatically agree to xilinx' and 3rd party eulas (which can be obtained by extracting the installer yourself) by running them. you also automatically agree to [apple's software licence agreement](https://www.apple.com/legal/sla/) for rosetta 2.

this repository contains the modified source code of [xvcd](https://github.com/tmbinc/xvcd) as well as a compiled version which is statically linked against [libusb](https://libusb.info/) and [libftdi](https://www.intra2net.com/en/developer/libftdi/). this is in accordance to the [lgpl version 2.1](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html), under which both of those libraries are licensed.

vivado and xilinx are trademarks of xilinx, inc.

arm is a registered trademark of arm limited (or its subsidiaries) in the us and/or elsewhere.

apple, mac, macbook, macbook air, macos and rosetta are trademarks of apple inc., registered in the u.s. and other countries and regions.

docker and the docker logo are trademarks or registered trademarks of docker, inc. in the united states and/or other countries. docker, inc. and other parties may also have trademark rights in other terms used herein.

intel and the intel logo are trademarks of intel corporation or its subsidiaries.

linux® is the registered trademark of linus torvalds in the u.s. and other countries.

oracle, java, mysql, and netsuite are registered trademarks of oracle and/or its affiliates. other names may be trademarks of their respective owners.

x window system is a trademark of the massachusetts institute of technology.
