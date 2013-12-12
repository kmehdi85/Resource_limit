#!/bin/bash

if [ `whoami` != "root" ]; then
        echo "This script needs to be run as root!"
        exit 1
fi

if [ -z /etc/debian_version ]; then
        echo "This script is made for Debian environments!"
        exit 1
fi

clear


echo  "Downloading the grsec patch and linux 3.12.2 file "
cd /usr/src
wget www.srishtisoft.com/grsec_patch_linux3.12.2.tgz
echo "Extracting the downloaded file"
tar -xzf  grsec_patch_linux3.12.2.tgz
mv grsec_patch_linux3.12.2/* /usr/src
 
echo  "==> Installing packages needed for building the kernel ... ";
apt-get update
apt-get -y -qq install build-essential bin86 kernel-package libncurses5-dev zlib1g-dev
if [ $? -eq 0 ]; then echo "Packages installed"; else echo "Installing packages failed"; exit 1; fi

GCC_VERSION=`apt-cache policy gcc | grep 'Installed:' | cut -c 16-18`
apt-get -y -qq install gcc-$GCC_VERSION-plugin-dev
if [ $? -eq 0 ]; then echo "GCC installed"; else echo "Installng GCC Failed"; exit 1; fi


if [ -h linux ]; then
        rm linux
fi


if [ ! -d linux-3.12.2 ]; then
        echo -n "==> Unarchiving linux-3.12.2.tar ... "
        tar -xf linux-3.12.2.tar
        if [ $? -eq 0 ]; then echo "Extracted linux file"; else echo "Failed Extracting linux file"; exit 1; fi
fi

if [ ! -d linux-3.12.2-grsec ]; then
        mv linux-3.12.2 linux-3.12.2-grsec
fi

ln -s linux-3.12.2-grsec linux
cd linux


echo -n "==> Applying patch ... "
patch -s -p1 < ../grsecurity-3.0-3.12.2-201312032145.patch
if [ $? -eq 0 ]; then echo "Grsec patch applied for new Kernel"; else echo "Failed applying Grsec patch"; exit 1; fi

cp /boot/config-`uname -r` .config
if [ -z `grep "CONFIG_GRKERNSEC=y" .config` ]; then
        echo "==> Current kernel doesn't seem to be running grsecurity. Running 'make menuconfig'"
        make menuconfig
else
        echo -n "==> Current kernel seems to be running grsecurity. Running 'make oldconfig' ... "
        yes "" | make oldconfig &> /dev/null
        if [ $? -eq 0 ]; then echo "OK"; else echo "Failed"; exit 1; fi
fi

echo -n "==> Building kernel ... "

make-kpkg clean &> /dev/null
if [ $? -eq 0 ]; then echo -n "phase 1 OK ... "; else echo "Failed"; exit 1; fi

make-kpkg --initrd --revision=201312032145 kernel_image
if [ $? -eq 0 ]; then echo "phase 2 OK ... "; else echo "Failed"; exit 1; fi

cd ..

echo -n "==> Installing kernel ... "
dpkg -i linux-image-3.12.2-grsec_`echo 201312032145`_*.deb
if [ $? -eq 0 ]; then echo "Installed new Kernel"; else echo "Failed installing new Kernel"; exit 1; fi


echo -n "==> Cleaning up ..."
rm linux-3.12.2.tar linux-3.12.2.tar.sign grsecurity-3.0-3.12.2-201312032145.patch grsecurity-3.0-3.12.2-201312032145.patch.sigscp 
if [ $? -eq 0 ]; then echo "OK"; else echo "Failed"; exit 1; fi
