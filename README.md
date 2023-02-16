# VisionFive-Nix

This repository contains primarily instructions for the VisionFive 1 board.

For experimental support for VisionFive 2, see [visionfive2/README.md](visionfive2/README.md).

# Flashing the Bootloader (VisionFive 1)

1. Do not apply power to the board
2. Attach the board via serial to your system, ensuring power is still not applied
3. Ensure the serial shows up in `/dev/ttyUSB*`, you can see this by running `dmesg` after plugging in the device

   ```
   ❯ dmesg
   [200199.253566] usb 1-2: new full-speed USB device number 79 using xhci_hcd
   [200199.386983] usb 1-2: New USB device found, idVendor=0403, idProduct=6001, bcdDevice= 6.00
   [200199.386988] usb 1-2: New USB device strings: Mfr=1, Product=2, SerialNumber=3
   [200199.386990] usb 1-2: Product: FT232R USB UART
   [200199.386991] usb 1-2: Manufacturer: FTDI
   [200199.386992] usb 1-2: SerialNumber: A50285BI
   [200199.390344] ftdi_sio 1-2:1.0: FTDI USB Serial Device converter detected
   [200199.390363] usb 1-2: Detected FT232RL
   [200199.391207] usb 1-2: FTDI USB Serial Device converter now attached to ttyUSB0
                                                                             ^^^^^^^
                                                                             ^ This becomes /dev/ttyUSB0
   ```

4. `nix run github:matthewcroughan/visionfive-nix#flashBootloader /dev/ttyUSB0`
5. Wait to be told to apply power to the board this may take a while as U-Boot and OpenSBI are being cross-compiled.
   ```
   Terminal ready

   ### Apply power to the VisionFive Board ###
   ```
   Once power is applied, picocom will send the OpenSBI/U-Boot payload via XMODEM. You can then flash NixOS or any other distribution that follows the Distro Boot specification[^1] to an SD card and boot it.

###### Why do I need to flash the bootloader?

https://github.com/starfive-tech/u-boot/issues/30

The VisionFive ships with a version of OpenSBI/U-Boot that does not follow the distro-boot specification. NixOS and other distros would like to remain generic, without vendor specific details entering their system. This means booting NixOS requires flashing the bootloader as described above.

[^1]: https://source.denx.de/u-boot/u-boot/-/blob/v2022.04/doc/develop/distro.rst
