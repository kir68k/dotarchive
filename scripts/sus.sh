sgdisk --zap-all "$DISK"
sgdisk -n1:2048:+550MiB -t1:ef00    -c1:"EFI system partition""$DISK"
# Size of luks header is 16MiB. So 1MiB keyfile
sgdisk -n2:0:+17MiB     -t2:8300    -c2:"cryptsetup luks key" "$DISK"
sgdisk -n3:0:+''${RAM}GiB -t3:8300    -c3:"swap space (hibernation)"  "$DISK"
sgdisk -n4:0:"$(sgdisk -E "$DISK")" -t4:8300    -c4:"root filesystem"     "$DISK"

cryptsetup luksFormat   "''${DISK}p2" --type luks2 --cipher serpent-xts-plain64 --key-size 512 --hash whirlpool --iter-time 10000
cryptsetup config "''${DISK}p2" --label NIXKEY
cryptsetup luksOpen     "''${DISK}p2" cryptkey
dd if=/dev/urandom of=/dev/mapper/cryptkey


cryptsetup luksFormat   "''${DISK}p3" --key-file=/dev/mapper/cryptkey --type luks2 --key-size 512 --hash whirlpool --iter-time 10000
cryptsetup config "''${DISK}p3" --label NIXSWAP
cryptsetup luksOpen     "''${DISK}p3" --key-file=/dev/mapper/cryptkey cryptswap
mkswap -L DECRYPTNIXSWAP /dev/mapper/cryptswap
sleep 2
swapon /dev/disk/by-label/DECRYPTNIXSWAP

cryptsetup luksFormat   "''${DISK}p4" --type luks2 --cipher serpent-xts-plain64 --key-size 512 --hash whirlpool --iter-time 10000
cryptsetup config "''${DISK}p4" --label NIXROOT
cryptsetup luksAddKey   "''${DISK}p4" /dev/mapper/cryptkey
cryptsetup luksOpen     "''${DISK}p4" --key-file=/dev/mapper/cryptkey cryptroot
mkfs.xfs -L DECNIXROOT -m bigtime=1 /dev/mapper/cryptroot
mkdir /mnt
mount /dev/disk/by-label/DECNIXROOT /mnt

mkfs.vfat -n EFI "''${DISK}p1"
mkdir /mnt/boot
mount /dev/disk/by-label/EFI /mnt/boot

nixos-generate-config --root /mnt
