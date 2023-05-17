#!/bin/bash
echo Welcome to Arch linux installtion script by A B Shavan krishna

# Set the keyboard layout
loadkeys us

# Update the system clock
timedatectl set-ntp true

# Create partitions on the hard drive
# You can customize the partition layout to your needs
parted /dev/sda mklabel gpt
parted /dev/sda mkpart primary ext4 1MiB 100GiB
parted /dev/sda set 1 boot on
parted /dev/sda mkpart primary linux-swap 100GiB 104GiB
parted /dev/sda mkpart primary ext4 104GiB 100%

# Format the partitions
mkfs.ext4 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3

# Mount the partitions
mount /dev/sda1 /mnt
swapon /dev/sda2
mkdir /mnt/home
mount /dev/sda3 /mnt/home

# Install the base system
pacstrap /mnt base base-devel

# Generate an fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the new system
arch-chroot /mnt /bin/bash

# Set the time zone
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc

# Configure the localization settings
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set the hostname
echo "myhostname" > /etc/hostname

# Create the hosts file
echo "127.0.0.1   localhost" >> /etc/hosts
echo "::1         localhost" >> /etc/hosts
echo "127.0.1.1   myhostname.localdomain  myhostname" >> /etc/hosts

# Install and configure the bootloader (grub)
pacman -S grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Exit the chroot environment
exit
echo Thank you for my script for installation 
# Unmount the partitions
umount -R /mnt


# Reboot the system
reboot
