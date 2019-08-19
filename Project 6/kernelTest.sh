#!/bin/bash
exit
cp /boot/config-3.19.0-43-generic ~/OS/linux-4.4.50/.config
cd /home/student/OS
echo "copy the folders bott/* in /boot"
sudo cp -rf boot/* /boot
echo "copy the folders mods/* in /"
sudo cp -rf mods/* /
sudo update-initramfs -u -k 4.4.50
sudo update-grub
echo "DONE"
