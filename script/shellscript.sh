#!/system/bin/sh
# ZeetaaTweaks V0.2
# By @NotZeetaa (Github)

sleep 120

SC=/sys/devices/system/cpu/cpu0/cpufreq/schedutil
KP=/sys/module/kprofiles
LOG=/data/ZTS
TP=/dev/stune/top-app/uclamp.max
DV=/dev/stune
CP=/dev/cpuset

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
# Credits to SpiderMoon
# echo "1000000" > /proc/sys/kernel/sched_migration_cost_ns

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
# The stat_interval one, reduces jitter (Credits to tytydraco)
echo "$(date "+%H:%M:%S") * Applying Ram Tweaks" >> $LOG/log.txt
sleep 0.5
echo "50" > /proc/sys/vm/vfs_cache_pressure
echo "10" > /proc/sys/vm/stat_interval
echo "$(date "+%H:%M:%S") * Applied Ram Tweaks" >> $LOG/log.txt
echo " " >> $LOG/log.txt

# Set 5 to perf_cpu_time_max_percent
echo "5" > /proc/sys/kernel/perf_cpu_time_max_percent

# Cgroup Boost
echo "$(date "+%H:%M:%S") * Checking which scheduler has ur kernel" >> $LOG/log.txt
sleep 0.5
if [ -d $TP ]; then
  # Uclamp Tweaks
  # All credits to @darkhz
  echo "$(date "+%H:%M:%S") * You have uclamp scheduler" >> $LOG/log.txt
  echo "$(date "+%H:%M:%S") * Applying tweaks for it" >> $LOG/log.txt
  sleep 0.3
  sysctl -w kernel.sched_util_clamp_min_rt_default=96
  sysctl -w kernel.sched_util_clamp_min=128
  echo "max" > $CP/top-app/uclamp.max
  echo "10" > $CP/top-app/uclamp.min
  echo "1" > $CP/top-app/uclamp.boosted
  echo "1" > $CP/top-app/uclamp.latency_sensitive
  echo "50" > $CP/foreground/uclamp.max
  echo "0" > $CP/foreground/uclamp.min
  echo "0" > $CP/foreground/uclamp.boosted
  echo "0" > $CP/foreground/uclamp.latency_sensitive
  echo "max" > $CP/background/uclamp.max
  echo "20" > $CP/background/uclamp.min
  echo "0" > $CP/background/uclamp.boosted
  echo "0" > $CP/background/uclamp.latency_sensitive
  echo "40" > $CP/system-background/uclamp.max
  echo "0" > $CP/system-background/uclamp.min
  echo "0" > $CP/system-background/uclamp.boosted
  echo "0" > $CP/system-background/uclamp.latency_sensitive
  echo "$(date "+%H:%M:%S") * Done" >> $LOG/log.txt
  echo " " >> $LOG/log.txt
else
  echo "$(date "+%H:%M:%S") * You have normal cgroup scheduler" >> $LOG/log.txt
  echo "$(date "+%H:%M:%S") * Applying tweaks for it" >> $LOG/log.txt
  sleep 0.3
  echo "1" > $DV/top-app/schedtune.boost
  echo "1" > $DV/foreground/schedtune.boost
  echo "0" > $DV/background/schedtune.boost
  echo "$(date "+%H:%M:%S") * Done" >> $LOG/log.txt
  echo " " >> $LOG/log.txt
fi

# ipv4 tweaks
# Reduce Net Ipv4 Performance Spikes
# By @Panchajanya1999
echo "0" > /proc/sys/net/ipv4/tcp_timestamps
chmod 444 /proc/sys/net/ipv4/tcp_timestamps

# Enable ECN negotiation by default
# By kdrg0n
echo "1" > /proc/sys/net/ipv4/tcp_ecn

# Always allow sched boosting on top-app tasks
# Credits to tytydraco
echo "0" > /proc/sys/kernel/sched_min_task_util_for_colocation

echo "$(date "+%H:%M:%S") * The Tweak is done enjoy :)" >> $LOG/log.txt
