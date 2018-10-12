JOBS?=1
BASE_DIR=../..
WRT_DIR=$(BASE_DIR)/openwrt
STAGING_DIR=$(WRT_DIR)/staging_dir
RISCV=$(STAGING_DIR)/toolchain-riscv64_riscv64_gcc-7.3.0_glibc
bbl-vmlinux=bbl-vmlinux.bin
rootfs=openwrt-riscv64-ext4.img

build_openwrt:
	( \
		cd openwrt && \
		cp ../openwrt.config .config && \
		sed -i 's?_EXT_KERNEL_TREE_?'`pwd`/../riscv-linux'?' .config && \
		$(MAKE) defconfig && \
		$(MAKE) V=s -j$(JOBS) \
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
			--with-payload=../../openwrt/bin/targets/riscv64/generic-glibc/openwrt-riscv64-vmlinux.elf \
			--enable-print-device-tree && \
		STAGING_DIR=$(STAGING_DIR) $(MAKE) -j$(JOBS) bbl && \
		mkdir -p ../../bin && \
		$(RISCV)/bin/riscv64-openwrt-linux-objcopy -S -O binary --change-addresses -0x80000000 bbl ../../bin/$(bbl-vmlinux) && \
		cp -f ../../openwrt/bin/targets/riscv64/generic-glibc/$(rootfs) ../../bin/ \
	)


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
		-append "earlyprintk root=/dev/vda rootwait" \
		-drive file=openwrt/bin/targets/riscv64/generic-glibc/openwrt-riscv64-ext4.img,format=raw,id=hd0 \
		-device virtio-blk-device,drive=hd0 \
		-netdev user,id=usernet,hostfwd=tcp::5522-:22 \
		-device virtio-net-device,netdev=usernet	
		

# ref: https://github.com/sifive/freedom-u-sdk/Makefile
# Relevant partition type codes
BBL   = 2E54B353-1271-4842-806F-E436D6AF6985
LINUX = 0FC63DAF-8483-4772-8E79-3D69D8477DE4

.PHONY: format-n-install-tf
format-n-install-tf:
	@test -b $(DISK) || (echo "$(DISK): is not a block device"; exit 1)
	sgdisk --clear                                                               \
		--new=1:2048:67583  --change-name=1:bootloader --typecode=1:$(BBL)   \
		--new=2:264192:     --change-name=2:root       --typecode=2:$(LINUX) \
		$(DISK)
	@sleep 1
ifeq ($(DISK)p1,$(wildcard $(DISK)p1))
	@$(eval PART1 := $(DISK)p1)
	@$(eval PART2 := $(DISK)p2)
else ifeq ($(DISK)s1,$(wildcard $(DISK)s1))
	@$(eval PART1 := $(DISK)s1)
	@$(eval PART2 := $(DISK)s2)
else ifeq ($(DISK)1,$(wildcard $(DISK)1))
	@$(eval PART1 := $(DISK)1)
	@$(eval PART2 := $(DISK)2)
else
	@echo Error: Could not find bootloader partition for $(DISK)
	@exit 1
endif
	dd if=bin/$(bbl-vmlinux) of=$(PART1) bs=4096
	dd if=bin/$(rootfs) of=$(PART2) bs=4096

