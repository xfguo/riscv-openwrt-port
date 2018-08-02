How to build
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

Run OpenWrt on Freedom Unleashed Board
--------------------------------------

First, prepare your TF card and find out the tf **disk** path (not partation). Eg /dev/sdb or /dev/mmcblk0)

Then execute:

```
sudo make format-n-install-tf DISK=*disk_path*
```

Insert the TF card to SiFive Unleashed board and enjoy~

Porting Status
--------------

- [x] binutils 2.30 (upstream)
- [x] gcc 7.3.0 (upstream)
- [x] glibc 2.27 (upsteam)
- [x] linux 4.15.18 (upstream)

----

Contributers:

- Alex Guo <xfguo@xfguo.org>

Thanks:

- Yousong Zhou
