![IMG_20220530_225120](https://user-images.githubusercontent.com/67799176/171062389-24c1c096-f991-449f-b962-45f145b95355.jpg)
# YAKT
**Yet Another Kernel Tweaker**. A Magisk module to Tweak your Kernel parameters. This module applies at boot and it's not an AI module.

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
## Benchmark

### - `Hackbench` with -pTl 4000 (lower is better)

- Stock: `Time: 6.632`
- yakt: `Time: 2.205`

### - `Callbench` (lower is better)

- Stock:
`syscall: 138 ns
libc: 43 ns
mmap: 11220 ns
read: 5290 ns`

- yakt:
`syscall: 138 ns
libc: 43 ns
mmap: 11212 ns
read: 4598 ns`

## Notes:
- This is not a perfomance/gaming module

## How to flash:
- Just flash in magisk and reboot
- And that's it ;)

## How to check logs:
- Check yakt.log file in documents folder
- It should be like this (Not exactly ofc):

![Screenshot_20221105-133527_MT_Manager](https://user-images.githubusercontent.com/67799176/200122575-dc72aedb-3618-4172-8b81-27cbdc721247.png)

## How to Contribute:
- Fork the Repo
- Edit tweaks according to your info/docs
- Commit with proper name and info/docs about what you did
- Test the change you did and check if eveything it's fine
- Then make a pull request
