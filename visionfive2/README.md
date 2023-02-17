
# VisionFive 2

As of writing, VisionFive 2 support is quite experimental; see [kernel/README.md](kernel/README.md).

## Flash the bootloader via serial connection

This step may be optional.

Make the serial connection according to the section "Recovering the Bootloader" in <https://doc-en.rvspace.org/VisionFive2/PDF/VisionFive2_QSG.pdf>.
Flip the tiny switches towards the H (as opposed to L) marking on the PCB (towards edge of the board) as described that section (Step 2).
Power up, and assuming your serial device is `/dev/ttyUSB0`, run:

```shellSession
nix run .#visionFive2_bootloader_recover /dev/ttyUSB0
```

## Write a bootable SD card

```shellSession
$ nix build .#images.visionfive2-cross
```

Insert an SD card of which all contents will be replaced.

These instructions assume your SD card reader is `/dev/mmcblk0`.

Make sure no partitions are mounted.

```shellSession
$ echo /dev/mmcblk0p*
$ sudo umount /dev/mmcblk0p1
$ sudo umount /dev/mmcblk0p2
... repeat for all partitions
```

`pv` provides a rough progress indicator based on the compressed size.
If you don't have `pv`, run in `nix shell nixpkgs#pv` or use `cat` instead.

```shellSession
$ sudo sh -c 'pv <result/sd-image/nixos-sd-image-*.img.zst | zstd -d | dd of=/dev/mmcblk0'
$ sync
```

## Other commands

### Enter the firmware recovery via serial

Prepare as you would for flashing the bootloader, and then:

```shellSession
nix run .#visionFive2_recovery_start /dev/ttyUSB0
```

### Establish a serial connection

Compatible with the recovery mode, but also suitable for the Linux terminal

```shellSession
nix run .#visionFive2_recovery_resume /dev/ttyUSB0
```
