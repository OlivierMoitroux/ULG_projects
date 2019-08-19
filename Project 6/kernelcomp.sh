#!/bin/bash

read -p 'Compile modules or not [y/n]: ' compileMods

cd /home/olivier/OS/linux-4.4.50
echo "Making old config\n"
make ARCH=i386 oldconfig
export ARCH=i386
make oldconfig

echo "Compiling kernel\n"
make ARCH=i386 bzImage -j3

if [ 'y' = "$compileMods" ];
then
        echo "Compiling modules"
        make ARCH=i386 modules -j3
else
        echo "Won't compile modules!"
fi


mkdir /home/olivier/OS/boot
echo "Exporting install path\n"
export INSTALL_PATH=/home/olivier/OS/boot
mkdir /home/olivier/OS/mods
echo "Exporting mods install path\n"
export INSTALL_MOD_PATH=/home/olivier/OS/mods
echo "Installing kernel\n"
make ARCH=i386 install -j3

if [ 'y' = "$compileMods" ];
then
	echo "Installing modules\n"
	make ARCH=i386 modules_install -j3
else
        echo "Won't install modules!"
fi
