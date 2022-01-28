#!/bin/sh
# ZeetaaTweaks V0.1
# By @NotZeetaa (Github)

sleep 20

SC=/sys/devices/system/cpu/cpu0/cpufreq/schedutil
KP=/sys/module/kprofiles
LOG=/sdcard/
echo "# ZeetaaTweaks V0.1" > $LOG/log.txt
echo "# Build Date: 28/01/2022" >> $LOG/log.txt
echo "# By @NotZeetaa (Github)" >> $LOG/log.txt

# Use Google's schedutil rate-limits from Pixel 3
# Credits to Kdrag0n
if [ -e $SC ]; then
  echo "500" > $SC/up_rate_limit_us
  echo "20000" > $SC/down_rate_limit_us
fi
  
# Tweak aims to have less Latency
# Credits to Tytydraco
echo "5000000" > /proc/sys/kernel/sched_migration_cost_ns

# Kprofiles Tweak
# Credits to cyberknight
if [ -d $KP ]; then
  echo "Your Kernel Supports Kprofiles" > $LOG/log.txt
  echo "2" > $KP/parameters/mode
else
  echo "⚠️ Your Kernel doesn't support Kprofiles" >> $LOG/log.txt
  echo "Not a big trouble, its normal" >> $LOG/log.txt
fi

# Less Ram Usage
# The stat_interval one, reduces jitter (Credits to kdrag0n)
echo "50" > /proc/sys/vm/vfs_cache_pressure
echo "20" > /proc/sys/vm/stat_interval
