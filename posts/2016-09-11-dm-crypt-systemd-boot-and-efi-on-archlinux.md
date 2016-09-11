---
layout: post
title: dm-crypt, luks, systemd-boot and UEFI on Archlinux.
date:  2016-09-11 17:45:13
category: ArchLinux SystemdBoot EFI dm-crypt
---

Here I provide a little help for setting up an archlinux system with full disk
encryption, efi and using systemd-boot as the boot loader. This is really just
what I learned from the [arch wiki], [Mattias Lundberg's gist]
and [Brandon Kester's post]. I'll assume you have installed arch before and
just need a little help getting everything up and running.

Desired setup:
```
100M /boot
100G /root
8G swap
the rest for /home
```

*Unlike [Mattias Lundberg] I see no reason for separate `boot` and `efi`
patitions.* Although some people have a problem with having their /boot in
fat32 due to permissions reasons.


This will be in 3 parts:

 - Partitioning, encrypting and repartitioning.
 - Installing the base system(arch).
 - Configuring the bootloader.

## Partitioning, encrypting and repartitioning.

```bash
# I like gdisk.
gdisk /dev/sdX

# Clear everything
-> o

# The first 100M efi partition
-> n -> ... -> +100M -> ... -> EF00

# power through this by always pressing enter.
# default hex code is 8E00
-> n -> ...  -> 8E00
```

Expected gdisk output should be 2 partitions, something along the lines of:
```bash
# In the end `p` in gdisk or `gdisk -l` should give you two partitions along the lines of:

# Device      Start       End   Sectors   Size Type
# /dev/sda1    2048    514047    512000   250M EFI System
# /dev/sda2  514048 976773134 976259087 465.5G Linux filesystem
```


#### Format, encrypt, repartition and format respectively.
The steps would be as follows:

- Format sdX1 in fat32
- Encrypt sdX2
    - Decrypt and repartition
    - format the partitions in ext4

```bash
# EFI only works with FAT32 so we format the 100M patition with FAT 32
mkfs.vfat -F32 /dev/sdX1

# Let's encrypt the other partition.
cryptsetup -c aes-xts-plain64 -y --use-random luksFormat /dev/sdX2

# Let's access our encrypted partition.
cryptsetup luksOpen /dev/sdX2 luks

# Now to create partitions inside the encrypted partition. /root /home and /swap
pvcreate /dev/mapper/luks
vgcreate vg0 /dev/mapper/luks
lvcreate --size 8G vg0 --name swap
lvcreate --size 100G vg0 --name root
lvcreate -l +100%FREE vg0 --name home

# Your /dev/mapper should now have:
#   /dev/mapper/vg0-home
#   /dev/mapper/vg0-root
#   /dev/mapper/vg0-swap


# Create file systems on the encrypted partitions.
# I don't know much about file systems so I just go with ext4.
mkfs.ext4 /dev/mapper/vg0-root
mkfs.ext4 /dev/mapper/vg0-home
mkswap /dev/mapper/vg0-swap


# Mount the partitions.
# Make sure to start with the root.
mount /dev/mapper/vg0-root /mnt
swapon /dev/mapper/vg0-swap    # Not needed but a good thing to test


mkdir /mnt/boot
mount /dev/sdX1 /mnt/boot


mkdir /mnt/home
mount /dev/mapper/vg0-home /mnt/home
```



## Install arch

```bash
# Install the base system
pacstrap /mnt base base-devel
```

#### Generate fstab

```bash
genfstab -pU /mnt >> /mnt/etc/fstab


# Make /tmp a ramdisk (add the following line to /mnt/etc/fstab)
tmpfs	/tmp	tmpfs	defaults,noatime,mode=1777	0	0
```

Verify that your fstab makes sense.

> *Change relatime on all non-boot partitions to noatime (reduces wear if using an SSD)*

For example:

```bash
#
# /etc/fstab: static file system information
#
# <file system> <dir>   <type>  <options>       <dump>  <pass>
# /dev/mapper/vg0-root
UUID=9a180980-d2bf-40d6-a09a-7a95a378f5e3       /               ext4            rw,relatime,data=ordered        0 1

# /dev/mapper/vg0-home
UUID=01e98383-e71a-4319-a70c-348783b1fc4c       /home           ext4            rw,relatime,data=ordered        0 2

# /dev/sda1
UUID=F679-59DA          /boot           vfat            rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro    0 2

# make /tmp a ramdisk
tmpfs                   /tmp            tmpfs           defaults,noatime,mode=1777                              0 0
```

#### chroot
```bash
# chroot into the new system
arch-chroot /mnt

# Setup system clock
ln -s /usr/share/zoneinfo/Africa/Nairobi /etc/localtime
hwclock --systohc --utc

# Set the hostname
echo <cool-comp-name> > /etc/hostname

# Update locale
echo LANG=en_US.UTF-8 >> /etc/locale.conf

# set password for root
passwd

# add a sudo group because that's cool
groupadd sudo

# Add a user
useradd -m -g sudo -s /bin/zsh <username>
passwd <username>

# add your user to sudoers
visudo
```
#### mkinitcpio

Configure mkinitcpio with modules needed for the initrd image.

Add 'ext4' to MODULES (or whatever fs you use)

Add 'encrypt', 'lvm2' and 'resume' to HOOKS before filesystems

`MODULES` and `HOOKS` should be something along the following lines:
```bash
less /etc/mkinitcpio.con
  MODULES="ext4"
  .
  .
  .
  HOOKS="base udev autodetect modconf block keymap encrypt lvm2 resume filesystems keyboard fsck"
```

## Configure the bootloader.
```bash
# Given you mounted /dev/sdX1 on /mnt/boot
bootctl --path=/boot install


# Populate the systemd-boot configs
blkid /dev/sda2 | awk '{print $2}' | sed 's/"//g' > /boot/loader/entries/arch.conf
```

Edit the config generated above.
Use `allow-discards` when using an SSD

To quote [Brandon Kester's post]:

*"The resume= option will enable hibernation on the device.
The nice thing about having an encrypted swap partition is that your hibernation
data will be encrypted just like the rest of the at-rest data.
This makes hibernation a very secure alternative to leaving your
machine in stand-by mode, which is vulnerable to the cold boot attack."*

Your /boot/loader/entries/arch.conf should be along the lines of:

```bash
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options cryptdevice=UUID=53f48717-2f23-466d-aad8-ce513286af42:lvm:allow-discards resume=/dev/mapper/vg0-swap root=/dev/mapper/vg0-root home=/dev/mapper/vg0-home rw quiet
```
 /boot/loader/loader.conf should be along the lines of:
note default arch refers to the entries/arch.conf from above
I like 0 timeout because speed /boot/loader/loader.conf
```bash
timeout 0
default arch
editor 0
```

Finishing up.

```bash
# generate the ramdisk
mkinitcpio -p linux

# I hope your /boot is sane.
# Mine is along the lines of:
$ tree /boot
/boot
├── EFI
│   ├── BOOT
│   │   └── BOOTX64.EFI
│   └── systemd
│       └── systemd-bootx64.efi
├── initramfs-linux-fallback.img
├── initramfs-linux.img
├── loader
│   ├── entries
│   │   └── arch.conf
│   └── loader.conf
└── vmlinuz-linux

5 directories, 7 files

# exit the chroot
exit

# unmount the drives
umount /mnt/home
umount /mnt/boot
umount /mnt

# yaaay
reboot
```

[systemd-boot]: https://wiki.archlinux.org/index.php/Systemd-boot
[Mattias Lundberg]: https://github.com/mattiaslundberg
[arch wiki]: https://wiki.archlinux.org/
[Mattias Lundberg's gist]: https://gist.github.com/mattiaslundberg/8620837
[Brandon Kester's post]: http://www.brandonkester.com/tech/2014/03/16/full-disk-encryption-in-arch-linux-with-uefi.html
