#!/system/bin/sh
# ZeetaaTweaks V1
# By @NotZeetaa (Github)

SC=/sys/devices/system/cpu/cpu0/cpufreq/schedutil
KP=/sys/module/kprofiles
LOG=/sdcard/ZeetaaTweaks.log
TP=/dev/stune/top-app/uclamp.max
DV=/dev/stune
CP=/dev/cpuset

echo "# ZeetaaTweaks V1" > $LOG
echo "# Build Date: 05/03/2022" >> $LOG
echo "# By @NotZeetaa (Github)" >> $LOG
echo " " >> $LOG
echo "###################################" >> $LOG
echo "#      Current ZTS mode: Performance    #" >> $LOG
echo "###################################" >> $LOG
echo " " >> $LOG
echo "$(date "+%H:%M:%S") * Device: $(getprop ro.product.system.model)" >> $LOG
echo "$(date "+%H:%M:%S") * Kernel: $(uname -r)" >> $LOG
echo "$(date "+%H:%M:%S") * Android Version: $(getprop ro.system.build.version.release)" >> $LOG
echo " " >> $LOG

# Use Google's schedutil rate-limits from Pixel 3
# Credits to Kdrag0n
echo "$(date "+%H:%M:%S") * Applying Google's schedutil rate-limits from Pixel 3" >> $LOG
if [ -e $SC ]; then
  echo 500 > $SC/up_rate_limit_us
  echo 20000 > $SC/down_rate_limit_us
  echo "$(date "+%H:%M:%S") * Applied Google's schedutil rate-limits from Pixel 3" >> $LOG
else
  echo "$(date "+%H:%M:%S") * Abort You are not using schedutil governor" >> $LOG
fi
echo " " >> $LOG
  
# Tweak aims to have less Latency
# Credits to SpiderMoon and Rhoan
# echo "$(date "+%H:%M:%S") * Tweaking to Reduce Latency [BETA]" >> $LOG
# echo 128 > /proc/sys/kernel/sched_nr_migrate
# sleep 0.5
# echo "$(date "+%H:%M:%S") * Done [BETA]" >> $LOG
# echo " " >> $LOG

# Kprofiles Tweak
# Credits to cyberknight
if [ -d $KP ]; then
  echo "$(date "+%H:%M:%S") * Your Kernel Supports Kprofiles" >> $LOG
  echo 3 > $KP/parameters/mode
else
  echo "$(date "+%H:%M:%S") * Your Kernel doesn't support Kprofiles, not a big trouble, it's normal" >> $LOG
  echo " " >> $LOG
fi

# Less Ram Usage
# The stat_interval one, reduces jitter (Credits to tytydraco)
# Credits to RedHat for dirty_ratio
echo "$(date "+%H:%M:%S") * Applying Ram Tweaks" >> $LOG
echo 50 > /proc/sys/vm/vfs_cache_pressure
echo 10 > /proc/sys/vm/stat_interval
echo "$(date "+%H:%M:%S") * Applied Ram Tweaks" >> $LOG
echo " " >> $LOG

# Set 15 to perf_cpu_time_max_percent
echo "$(date "+%H:%M:%S") * Applying tweak for perf_cpu_time_max_percent" >> $LOG
echo 15 > /proc/sys/kernel/perf_cpu_time_max_percent
echo "$(date "+%H:%M:%S") * Done" >> $LOG
echo " " >> $LOG

# Disable Timer migration
echo "$(date "+%H:%M:%S") * Disabling Timer Migration" >> $LOG
echo 0 > /proc/sys/kernel/timer_migration
echo "$(date "+%H:%M:%S") * Done" >> $LOG
echo " " >> $LOG

# Cgroup Boost
echo "$(date "+%H:%M:%S") * Checking which scheduler your kernel has" >> $LOG
if [ -e $TP ]; then
  # Uclamp Tweaks
  # All credits to @darkhz
  echo "$(date "+%H:%M:%S") * You have uclamp scheduler" >> $LOG
  echo "$(date "+%H:%M:%S") * Applying tweaks for it" >> $LOG
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
echo 0 > /proc/sys/net/ipv4/tcp_timestamps
chmod 444 /proc/sys/net/ipv4/tcp_timestamps

# Enable ECN negotiation by default
# By kdrg0n
echo 1 > /proc/sys/net/ipv4/tcp_ecn

# Always allow sched boosting on top-app tasks
# Credits to tytydraco
echo "$(date "+%H:%M:%S") * Always allow sched boosting on top-app tasks" >> $LOG
echo 0 > /proc/sys/kernel/sched_min_task_util_for_colocation
echo "$(date "+%H:%M:%S") * Done" >> $LOG
echo " " >> $LOG

# Watermark Boost Tweak
echo "$(date "+%H:%M:%S") * Checking your linux version to tweak watermark boost" >> $LOG
if cat /proc/version | grep -w "4.19"
then
  echo "$(date "+%H:%M:%S") * Found 4.19 kernel disabling it because doesn't work..." >> $LOG
  echo 0 > /proc/sys/vm/watermark_boost_factor
  echo "$(date "+%H:%M:%S") * Done!" >> $LOG
elif cat /proc/version | grep -w "5.4"
then
  echo "$(date "+%H:%M:%S") * Found 5.4 kernel tweaking it..." >> $LOG
  echo 1500 > /proc/sys/vm/watermark_boost_factor
  echo "$(date "+%H:%M:%S") * Done!" >> $LOG
elif cat /proc/version | grep -w "5.10"
then
  echo "$(date "+%H:%M:%S") * Found 5.10 kernel tweaking it..." >> $LOG
  echo 1500 > /proc/sys/vm/watermark_boost_factor
  echo "$(date "+%H:%M:%S") * Done!" >> $LOG
elif cat /proc/version | grep -w "5.15"
then
  echo "$(date "+%H:%M:%S") * Found 5.15 kernel tweaking it..." >> $LOG
  echo 1500 > /proc/sys/vm/watermark_boost_factor
  echo "$(date "+%H:%M:%S") * Done!" >> $LOG
elif cat /proc/version | grep -w "5.16"
then
  echo "$(date "+%H:%M:%S") * Found 5.16 kernel tweaking it..." >> $LOG
  echo 1500 > /proc/sys/vm/watermark_boost_factor
  echo "$(date "+%H:%M:%S") * Done!" >> $LOG
elif cat /proc/version | grep -w "5.17"
then
  echo "$(date "+%H:%M:%S") Found 5.17 kernel tweaking it..." >> $LOG
  echo 1500 > /proc/sys/vm/watermark_boost_factor
  echo "$(date "+%H:%M:%S") * Done!" >> $LOG
else
  echo "$(date "+%H:%M:%S") * Your linux kernel version doesn't support watermark boost" >> $LOG
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
echo "$(date "+%H:%M:%S") * [BETA] Checking if your kernel has UFS Turbo Write Support" >> $LOG
if [ -e /sys/devices/platform/soc/1d84000.ufshc/ufstw_lu0/tw_enable ]; then
  echo "$(date "+%H:%M:%S") * [BETA] Your kernel has UFS Turbo Write Support. Tweaking it..." >> $LOG
  echo 1 > /sys/devices/platform/soc/1d84000.ufshc/ufstw_lu0/tw_enable
  echo "$(date "+%H:%M:%S") * [BETA] Done!" >> $LOG
else
  echo "$(date "+%H:%M:%S") * [BETA] Your kernel doesn't have UFS Turbo Write Support." >> $LOG
fi
echo " " >> $LOG

echo "$(date "+%H:%M:%S") * The Tweak is done enjoy :)" >> $LOG
