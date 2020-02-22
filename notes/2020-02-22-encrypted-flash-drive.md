---
layout: post
title: Encrypting and decypting a flash drive
date: 2020-02-22 11:35:58
tags: Encryption, Decryption
---

Note:

 - You need root for most of these commands
 - Replace X with the target drive letter


# Encrypting a flash drive that was previously unencrypted


1. Install cryptsetup
```
pacman -S cryptsetup
```

2. List your USB devices with either
```
lsblk
```
or
```
fdisk -l
```

3. Write random data to disk
```
shred -v -n 1 /dev/sdX
```
or
```
dd if=/dev/urandom of=/dev/sdX bs=1M
```

4. Set up a new dm-crypt device in LUKS encryption mode
```
cryptsetup luksFormat /dev/sdX
```

5. Set up mapping
```
cryptsetup luksOpen /dev/sdX flashy
```

6. Verify the new virtual block device mapper
```
ls -arlt /dev/mapper | tail
```

7. Format the disk with ext4
```
mkfs -t ext4 /dev/mapper/flashy
```

8. Create a mount location
```
mkdir /run/mount/flashy
```

9. Mount the device your filesystem:
```
mount /dev/mapper/flashy /run/mount/flashy
```

10. Verify the the mapper is properly mounted using the df command:
```
df -h /run/mount/flashy
```

# Accessing your flash drive later on.

1. Decrypt the flash drive
```
cryptsetup luksOpen /dev/sdX flashy 
```
Look it up
```
ls -arlt /dev/mapper | tail
```

2. Create a mount location
```
mkdir /run/mount/flashy
```

3. Mount the flash drive
```
mount /dev/mapper/flashy /run/mount/flashy
```

4. Access your files
```
cd /run/mount/flashy
```

5. Unmount the flash drive
```
umount /run/mount/flashy
```

6. Cleaup
```
rm -r /run/mount/flashy
```

7. Close your flash drive
```
cryptsetup luksClose flashy
```
