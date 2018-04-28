HOW TO BUILD
------------

```
# install requirements (for ubuntu 16.04)
$ sudo apt-get install python pkg-config libglib2.0-dev libpixman-1-dev git-core build-essential libssl-dev libncurses5-dev unzip gawk python2.7 subversion flex bison

# clone and update submodule
$ git clone https://github.com/xfguo/riscv-openwrt-port.git
$ cd riscv-openwrt-port
$ git submodule update --init --recursive

# build
$ make build_openwrt
$ make build_bbl
$ make build_qemu

# this will start qemu
$ make qemu
```

Author: Alex Guo <xfguo@xfguo.org>
