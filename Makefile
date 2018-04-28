JOBS?=1
BASE_DIR=../..
WRT_DIR=$(BASE_DIR)/openwrt
STAGING_DIR=$(WRT_DIR)/staging_dir
RISCV=$(STAGING_DIR)/toolchain-riscv64_riscv64_gcc-7.3.0_glibc

build_openwrt:
	( \
		cd openwrt && \
		cp ../openwrt.config .config && \
		sed -i 's?_EXT_KERNEL_TREE_?'`pwd`/../riscv-linux'?' .config && \
		$(MAKE) defconfig && \
		$(MAKE) -j$(JOBS) \
	)


build_bbl:
	( \
		mkdir -p build/bbl && rm build/bbl/* -rf && cd build/bbl && \
		CC=$(RISCV)/bin/riscv64-openwrt-linux-gcc \
		AR=$(RISCV)/bin/riscv64-openwrt-linux-ar \
		RANLIB=$(RISCV)/bin/riscv64-openwrt-linux-ranlib \
		OBJCOPY=$(RISCV)/bin/riscv64-openwrt-linux-objcopy \
		AS=$(RISCV)/bin/riscv64-openwrt-linux-as \
		READELF=$(RISCV)/bin/riscv64-openwrt-linux-readelf \
		../../riscv-pk/configure \
			--host=riscv64-unknown-linux-gnu \
			--with-payload=../../openwrt/linux/vmlinux \
			--enable-print-device-tree && \
		STAGING_DIR=$(STAGING_DIR) $(MAKE) bbl \
	)

			#--with-payload=../../openwrt/bin/targets/riscv64/generic-glibc/openwrt-riscv64-vmlinux.elf \

build_qemu:
	mkdir -p build/qemu
	( \
		cd build/qemu && \
		../../riscv-qemu/configure \
			--target-list="riscv64-softmmu" && \
		$(MAKE) -j$(JOBS) \
	)



qemu:
	./build/qemu/riscv64-softmmu/qemu-system-riscv64 \
		-nographic \
		-machine virt \
		-kernel build/bbl/bbl \
		-drive file=openwrt/bin/targets/riscv64/generic-glibc/openwrt-riscv64-ext4.img,format=raw,id=hd0 \
		-device virtio-blk-device,drive=hd0 \
		-netdev user,id=usernet,hostfwd=tcp::5522-:22 \
		-device virtio-net-device,netdev=usernet	
