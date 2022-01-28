#!/bin/sh
# ZeetaaTweaks V0.1
# By @NotZeetaa (Github)

sleep 20

SC=/sys/devices/system/cpu/cpu0/cpufreq/schedutil
KP=/sys/module/kprofiles
LOG=/data/ZTS

# Check if folder exist
# If not then remove and create a new one
if [ -d $LOG ]; then
  rm -rf $LOG
  mkdir -p $LOG
else
  mkdir -p $LOG
fi
echo "# ZeetaaTweaks V0.1" > $LOG/log.txt
echo "# Build Date: 28/01/2022" >> $LOG/log.txt
echo "# By @NotZeetaa (Github)" >> $LOG/log.txt
echo " " >> $LOG/log.txt
echo "$(date "+%H:%M:%S") * Device: $(getprop ro.product.system.model)" >> $LOG/log.txt
echo "$(date "+%H:%M:%S") * Kernel: $(uname -r)" >> $LOG/log.txt
echo "$(date "+%H:%M:%S") * Android Version: $(getprop ro.system.build.version.release)" >> $LOG/log.txt
echo " " >> $LOG/log.txt

# Use Google's schedutil rate-limits from Pixel 3
# Credits to Kdrag0n
echo "$(date "+%H:%M:%S") * Applying Google's schedutil rate-limits from Pixel 3" >> $LOG/log.txt
sleep 0.5
if [ -e $SC ]; then
  echo "500" > $SC/up_rate_limit_us
  echo "20000" > $SC/down_rate_limit_us
  echo "$(date "+%H:%M:%S") * Applied Google's schedutil rate-limits from Pixel 3" >> $LOG/log.txt
else
  echo "$(date "+%H:%M:%S") * Abort You are not using schedutil governor" >> $LOG/log.txt
fi
echo " " >> $LOG/log.txt
  
# Tweak aims to have less Latency
# Credits to Tytydraco
echo "5000000" > /proc/sys/kernel/sched_migration_cost_ns

# Kprofiles Tweak
# Credits to cyberknight
if [ -d $KP ]; then
  echo "$(date "+%H:%M:%S") * Your Kernel Supports Kprofiles" >> $LOG/log.txt
  echo "2" > $KP/parameters/mode
else
  echo "$(date "+%H:%M:%S") * Your Kernel doesn't support Kprofiles, not a big trouble, its normal" >> $LOG/log.txt
  echo " " >> $LOG/log.txt
fi

# Less Ram Usage
# The stat_interval one, reduces jitter (Credits to kdrag0n)
echo "$(date "+%H:%M:%S") * Applying Ram Tweaks" >> $LOG/log.txt
sleep 0.5
echo "50" > /proc/sys/vm/vfs_cache_pressure
echo "20" > /proc/sys/vm/stat_interval
echo "$(date "+%H:%M:%S") * Applied Ram Tweaks" >> $LOG/log.txt
echo " " >> $LOG/log.txt

# Set 5 to perf_cpu_time_max_percent
echo "5" > /proc/sys/kernel/perf_cpu_time_max_percent

# ipv4 tweaks
# Reduce Net Ipv4 Performance Spikes
# By @Panchajanya1999
echo "0" > /proc/sys/net/ipv4/tcp_timestamps
chmod 444 /proc/sys/net/ipv4/tcp_timestamps

# Enable ECN negotiation by default
# By kdrg0n
echo "1" > /proc/sys/net/ipv4/tcp_ecn

echo "$(date "+%H:%M:%S") * The Tweak is done enjoy :)" >> $LOG/log.txt
