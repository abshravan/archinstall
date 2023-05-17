#!/bin/bash

# Check if running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

# Set variables
USERNAME="your_username"
PASSWORD="your_password"
HOSTNAME="your_hostname"

# Set up disk partitioning
echo "Setting up disk partitioning..."
# (Replace /dev/sda with the appropriate disk device)
echo -e "o\nn\n\n\n\n+512M\nt\n1\nn\n\n\n\n\nw" | fdisk /dev/sda

# Format the partition
echo "Formatting the partition..."
mkfs.ext4 /dev/sda2

# Mount the partition
echo "Mounting the partition..."
mount /dev/sda2 /mnt

# Install the base system
echo "Installing the base system..."
pacstrap /mnt base linux linux-firmware

# Generate fstab
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Change root into the new system
echo "Changing root into the new system..."
arch-chroot /mnt /bin/bash <<EOF

# Set the time zone
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc

# Set the locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set the hostname
echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

# Set the root password
echo "Setting root password..."
echo -e "$PASSWORD\n$PASSWORD" | passwd

# Install and configure bootloader (GRUB)
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ArchLinux
grub-mkconfig -o /boot/grub/grub.cfg

# Enable NetworkManager
systemctl enable NetworkManager

# Install GNOME desktop environment
pacman -S gnome

# Enable GDM (GNOME Display Manager)
systemctl enable gdm

# Create a new user
echo "Creating a new user..."
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo -e "$PASSWORD\n$PASSWORD" | passwd "$USERNAME"

# Allow members of the wheel group to execute any command
sed -i 's/^# %wheel ALL=(ALL) ALL$/%wheel ALL=(ALL) ALL/' /etc/sudoers

EOF

# Unmount partitions and reboot
echo "Installation complete. Unmounting partitions and rebooting..."
umount -R /mnt
reboot
