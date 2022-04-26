#!/system/bin/sh
# ZeetaaTweaks V1.6
# By @NotZeetaa (Github)

sleep 60

SC=/sys/devices/system/cpu/cpu0/cpufreq/schedutil
KP=/sys/module/kprofiles
LOG=/sdcard/ZeetaaTweaks.log
DV=/dev/stune
CP=/dev/cpuset

TS=$(cat /proc/sys/net/ipv4/tcp_timestamps)
EC=$(cat /proc/sys/net/ipv4/tcp_ecn)
PS=$(cat /proc/version)

echo "# ZeetaaTweaks V1.6" > $LOG
echo "# Build Date: 03/03/2022" >> $LOG
echo "# By @NotZeetaa (Github)" >> $LOG
echo " " >> $LOG
echo "$(date "+%H:%M:%S") * Device: $(getprop ro.product.system.model)" >> $LOG
echo "$(date "+%H:%M:%S") * Kernel: $(uname -r)" >> $LOG
echo "$(date "+%H:%M:%S") * Android Version: $(getprop ro.system.build.version.release)" >> $LOG
echo " " >> $LOG

# Use Google's schedutil rate-limits from Pixel 3
# Credits to Kdrag0n
echo "$(date "+%H:%M:%S") * Applying Google's schedutil rate-limits from Pixel 3" >> $LOG
sleep 0.5
if [ -e $SC ]; then
  echo 500 > $SC/up_rate_limit_us
  echo 20000 > $SC/down_rate_limit_us
  echo "$(date "+%H:%M:%S") * Applied Google's schedutil rate-limits from Pixel 3" >> $LOG
else
  echo "$(date "+%H:%M:%S") * Abort You are not using schedutil governor" >> $LOG
fi
echo " " >> $LOG
  
# (Rewrited) Tweaks to have less Latency
# Credits to RedHat
echo "$(date "+%H:%M:%S") * Tweaking to Reduce Latency " >> $LOG
echo "15000000" > /proc/sys/kernel/sched_wakeup_granularity_ns
echo "10000000" > /proc/sys/kernel/sched_min_granularity_ns
sleep 0.5
echo "$(date "+%H:%M:%S") * Done " >> $LOG
echo " " >> $LOG

# Kprofiles Tweak
# Credits to cyberknight
if [ -d $KP ]; then
  echo "$(date "+%H:%M:%S") * Your Kernel Supports Kprofiles" >> $LOG
  echo 2 > $KP/parameters/mode
else
  echo "$(date "+%H:%M:%S") * Your Kernel doesn't support Kprofiles, not a big trouble, it's normal" >> $LOG
  echo " " >> $LOG
fi

# Less Ram Usage
# The stat_interval one, reduces jitter (Credits to kdrag0n)
# Credits to RedHat for dirty_ratio
echo "$(date "+%H:%M:%S") * Applying Ram Tweaks" >> $LOG
sleep 0.5
echo 50 > /proc/sys/vm/vfs_cache_pressure
echo 20 > /proc/sys/vm/stat_interval
echo "$(date "+%H:%M:%S") * Applied Ram Tweaks" >> $LOG
echo " " >> $LOG

# Set kernel.perf_cpu_time_max_percent to 15
echo "$(date "+%H:%M:%S") * Applying tweak for perf_cpu_time_max_percent" >> $LOG
echo 15 > /proc/sys/kernel/perf_cpu_time_max_percent
echo "$(date "+%H:%M:%S") * Done" >> $LOG
echo " " >> $LOG

# Disable some scheduler logs/stats
# Also iostats
# Credits to tytydraco
echo "$(date "+%H:%M:%S") * Disabling some scheduler logs/stats" >> $LOG
if [ -e /proc/sys/kernel/sched_schedstats ]; then
  echo 0 > /proc/sys/kernel/sched_schedstats
fi
echo off > /proc/sys/kernel/printk_devkmsg
for queue in /sys/block/*/queue
do
    echo 0 > "$queue/iostats"
done
echo "$(date "+%H:%M:%S") * Done" >> $LOG
echo " " >> $LOG

# Disable Timer migration
echo "$(date "+%H:%M:%S") * Disabling Timer Migration" >> $LOG
echo 0 > /proc/sys/kernel/timer_migration
echo "$(date "+%H:%M:%S") * Done" >> $LOG
echo " " >> $LOG

# Cgroup Boost
echo "$(date "+%H:%M:%S") * Checking which scheduler your kernel has" >> $LOG
sleep 0.5
if [ -e $TP ]; then
  # Uclamp Tweaks
  # All credits to @darkhz
  echo "$(date "+%H:%M:%S") * You have uclamp scheduler" >> $LOG
  echo "$(date "+%H:%M:%S") * Applying tweaks for it" >> $LOG
  sleep 0.3
  sysctl -w kernel.sched_util_clamp_min_rt_default=96
  sysctl -w kernel.sched_util_clamp_min=128
  echo max > $CP/top-app/uclamp.max
  echo 10 > $CP/top-app/uclamp.min
  echo 1 > $CP/top-app/uclamp.boosted
  echo 1 > $CP/top-app/uclamp.latency_sensitive
  echo 50 > $CP/foreground/uclamp.max
  echo 0 > $CP/foreground/uclamp.min
  echo 0 > $CP/foreground/uclamp.boosted
  echo 0 > $CP/foreground/uclamp.latency_sensitive
  echo max > $CP/background/uclamp.max
  echo 20 > $CP/background/uclamp.min
  echo 0 > $CP/background/uclamp.boosted
  echo 0 > $CP/background/uclamp.latency_sensitive
  echo 40 > $CP/system-background/uclamp.max
  echo 0 > $CP/system-background/uclamp.min
  echo 0 > $CP/system-background/uclamp.boosted
  echo 0 > $CP/system-background/uclamp.latency_sensitive
  echo "$(date "+%H:%M:%S") * Done" >> $LOG
  echo " " >> $LOG
else
  echo "$(date "+%H:%M:%S") * You have normal cgroup scheduler" >> $LOG
  echo "$(date "+%H:%M:%S") * Applying tweaks for it" >> $LOG
  sleep 0.3
  chmod 644 $DV/top-app/schedtune.boost
  echo 1 > $DV/top-app/schedtune.boost
  chmod 664 $DV/top-app/schedtune.boost
  echo 0 > $DV/top-app/schedtune.prefer_idle
  echo 1 > $DV/foreground/schedtune.boost
  echo 0 > $DV/background/schedtune.boost
  echo "$(date "+%H:%M:%S") * Done" >> $LOG
  echo " " >> $LOG
fi

# ipv4 tweaks
# Reduce Net Ipv4 Performance Spikes
# By @Panchajanya1999
if [[ "$TS" == *"0"* ]]
then
  :
else
  echo 0 > /proc/sys/net/ipv4/tcp_timestamps
  chmod 444 /proc/sys/net/ipv4/tcp_timestamps
fi

# Enable ECN negotiation by default
# By kdrg0n
if [[ "$EC" == *"1"* ]]
then
  :
else
  echo 1 > /proc/sys/net/ipv4/tcp_ecn
fi

# Always allow sched boosting on top-app tasks
# Credits to tytydraco
echo "$(date "+%H:%M:%S") * Always allow sched boosting on top-app tasks" >> $LOG
echo 0 > /proc/sys/kernel/sched_min_task_util_for_colocation
echo "$(date "+%H:%M:%S") * Done" >> $LOG
echo " " >> $LOG

# Watermark Boost Tweak
echo "$(date "+%H:%M:%S") * Checking your linux version to tweak watermark boost" >> $LOG
if [[ "$PS" == *"4.19"* ]]
then
  echo "$(date "+%H:%M:%S") * Found 4.19 kernel, disabling it because doesn't work..." >> $LOG
  echo 0 > /proc/sys/vm/watermark_boost_factor
  echo "$(date "+%H:%M:%S") * Done!" >> $LOG
elif [[ "$PS" == *"5.4"* ]]
then
  echo "$(date "+%H:%M:%S") * Found 5.4 kernel tweaking it..." >> $LOG
  echo 1500 > /proc/sys/vm/watermark_boost_factor
  echo "$(date "+%H:%M:%S") * Done!" >> $LOG
elif [[ "$PS" == *"5.10"* ]]
then
  echo "$(date "+%H:%M:%S") * Found 5.10 kernel tweaking it..." >> $LOG
  echo 1500 > /proc/sys/vm/watermark_boost_factor
  echo "$(date "+%H:%M:%S") * Done!" >> $LOG
elif [[ "$PS" == *"5.15"* ]]
then
  echo "$(date "+%H:%M:%S") * Found 5.15 kernel tweaking it..." >> $LOG
  echo 1500 > /proc/sys/vm/watermark_boost_factor
  echo "$(date "+%H:%M:%S") * Done!" >> $LOG
elif [[ "$PS" == *"5.16"* ]]
then
  echo "$(date "+%H:%M:%S") * Found 5.16 kernel tweaking it..." >> $LOG
  echo 1500 > /proc/sys/vm/watermark_boost_factor
  echo "$(date "+%H:%M:%S") * Done!" >> $LOG 
elif [[ "$PS" == *"5.17"* ]]
then
  echo "$(date "+%H:%M:%S") * Found 5.17 kernel tweaking it..." >> $LOG
  echo 1500 > /proc/sys/vm/watermark_boost_factor
  echo "$(date "+%H:%M:%S") * Done!" >> $LOG
else
  echo "$(date "+%H:%M:%S") * Your linux kernel version doesn't support watermark boost" >> $LOG
  echo "$(date "+%H:%M:%S") * Aborting it..." >> $LOG
  echo "$(date "+%H:%M:%S") * Done!" >> $LOG
fi
echo " " >> $LOG

echo "$(date "+%H:%M:%S") * Tweaking read_ahead overall" >> $LOG
for queue in /sys/block/*/queue/read_ahead_kb
do
echo 128 > $queue
done
echo "$(date "+%H:%M:%S") * Tweaked read_ahead" >> $LOG
echo " " >> $LOG

# [BETA] UTW (UFS Turbo Write Tweak)
echo "$(date "+%H:%M:%S") * Checking if your kernel has UFS Turbo Write Support" >> $LOG
if [ -e /sys/devices/platform/soc/1d84000.ufshc/ufstw_lu0/tw_enable ]; then
  echo "$(date "+%H:%M:%S") * Your kernel has UFS Turbo Write Support. Tweaking it..." >> $LOG
  echo 1 > /sys/devices/platform/soc/1d84000.ufshc/ufstw_lu0/tw_enable
  echo "$(date "+%H:%M:%S") * Done!" >> $LOG
else
  echo "$(date "+%H:%M:%S") * Your kernel doesn't have UFS Turbo Write Support." >> $LOG
fi
echo " " >> $LOG

# Extfrag
# Credits to @tytydraco
echo "$(date "+%H:%M:%S") * Increasing fragmentation index" >> $LOG
echo 750 > /proc/sys/vm/extfrag_threshold
sleep 0.5
echo "$(date "+%H:%M:%S") * Done!" >> $LOG
echo " " >> $LOG

echo "$(date "+%H:%M:%S") * The Tweak is done enjoy :)" >> $LOG
