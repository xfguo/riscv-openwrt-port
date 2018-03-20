HOW TO BUILD
------------

```
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
