![IMG_20210105_222157_267](https://user-images.githubusercontent.com/67799176/103706233-6f91f780-4fa4-11eb-877c-5d47a1c27cdb.jpg)
# YAKT
Yet Another Kernel Tweaker. A Magisk module to Tweak your Kernel parameters. This module applies at boot and it's not an AI module.

## Features:
- Reduces Jitter and Latency
- Optimizes Ram Management
- Uses Google's schedutil rate-limits from Pixel 3
- Tweaks kprofiles to balanced mode
- Disables scheduler logs/stats
- Reduces TCP Performance spikes
- Enable ECN negotiation by default
- Disables SPI CRC
- Allows sched boosting on top-app tasks (Thx to tytydraco)
- Cgroup Boost (Credits to darkhz for uclamp tweak)

## How to flash:
- Just flash in magisk and reboot
- And that's it ;)

## How to check logs:
- Check YAKT.log file in internal storage
- It should be like this (Not exactly ofc):

![Screenshot_20220303-203231_MT_Manager](https://user-images.githubusercontent.com/67799176/156649692-527751b0-05cb-4914-894e-c1686d58028c.png)
