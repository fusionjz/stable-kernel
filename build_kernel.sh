#!/bin/bash
#2.6.29-x45.1

KERNEL_REL=2.6.29
BUILD=x45.1
GIT=58cf2f1

#x86 use:
#CC=~/bin/arm-2009q1-203/bin/arm-none-linux-gnueabi-
CC=/OE/angstrom-dev/cross/armv7a/bin/arm-angstrom-linux-gnueabi-

#arm use:
#CC=

#USB patches is board specific
BOARD=beagleboard

DIR=$PWD

echo "checking for uboot-mkimage"
sudo apt-get install uboot-mkimage

mkdir -p ${DIR}/deploy/
mkdir -p ${DIR}/dl

wget -c --directory-prefix=${DIR}/dl/ http://www.kernel.org/pub/linux/kernel/v2.6/linux-${KERNEL_REL}.tar.bz2

function extract_kernel {
	tar xjf ${DIR}/dl/linux-${KERNEL_REL}.tar.bz2
	mv linux-${KERNEL_REL} KERNEL
}

function patch_kernel {

cd ${DIR}/KERNEL

export DIR KERNEL_REL GIT BOARD

/bin/bash ${DIR}/patch.sh

cd ${DIR}/
}

function copy_defconfig {
	cd ${DIR}/KERNEL/
	make ARCH=arm CROSS_COMPILE=${CC} distclean
	cp ${DIR}/patches/defconfig .config
	cd ${DIR}/
}

function make_menuconfig {
	cd ${DIR}/KERNEL/
	make ARCH=arm CROSS_COMPILE=${CC} menuconfig
	cd ${DIR}/
}

function make_uImage {
	cd ${DIR}/KERNEL/
	make -j2 ARCH=arm CROSS_COMPILE=${CC} uImage
	cp arch/arm/boot/uImage ${DIR}/deploy/${KERNEL_REL}-${BUILD}.uImage
	cd ${DIR}
}

function make_modules {
	cd ${DIR}/KERNEL/
	make -j2 ARCH=arm CROSS_COMPILE=${CC} modules
	mkdir -p ${DIR}/deploy/mod
	make ARCH=arm CROSS_COMPILE=${CC} modules_install INSTALL_MOD_PATH=${DIR}/deploy/mod
	cd ${DIR}/deploy/mod
	tar czf ../${KERNEL_REL}-${BUILD}-modules.tar.gz *
	cd ${DIR}
}

extract_kernel
patch_kernel
copy_defconfig
make_menuconfig
make_uImage
make_modules


