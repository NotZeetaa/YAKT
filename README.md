![IMG_20220530_225120](https://user-images.githubusercontent.com/67799176/171062389-24c1c096-f991-449f-b962-45f145b95355.jpg)
# YAKT
Yet Another Kernel Tweaker. A Magisk module to Tweak your Kernel parameters. This module applies at boot and it's not an AI module.

## Features:
```
- Reduces Jitter and Latency
- Optimizes Ram Management
- Uses Google's schedutil rate-limits from Pixel 3
- Tweaks kprofiles to balanced mode
- Disables scheduler logs/stats
- Enable ECN negotiation by default
- Disables SPI CRC
- Tweaks mglru a bit
- Allows sched boosting on top-app tasks (Thx to tytydraco)
- Cgroup Boost (Credits to darkhz for uclamp tweak)
- It's Open Source!
```

## Notes:
- This is not a perfomance/gaming module

## How to flash:
- Just flash in magisk and reboot
- And that's it ;)

## How to check logs:
- Check yakt.log file in internal storage
- It should be like this (Not exactly ofc):

![Screenshot_20220303-203231_MT_Manager](https://user-images.githubusercontent.com/67799176/156649692-527751b0-05cb-4914-894e-c1686d58028c.png)

## How to Contribute:
- Fork the Repo
- Edit tweaks according to your info/docs
- Commit with proper name and info/docs about what you did
- Test the change you did and check if eveything it's fine
- Then make a pull request
