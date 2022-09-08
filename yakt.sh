#!/system/bin/sh
# Yakt v3
# Author: @NotZeetaa (Github)

sleep 60

SC=/sys/devices/system/cpu/cpu0/cpufreq/schedutil
KP=/sys/module/kprofiles
if [ ! -d /sdcard/Documents ]; then
  LOG=/sdcard/yakt.log
else
  if [ ! -d /sdcard/Documents/yakt ]; then
    mkdir /sdcard/Documents/yakt
    LOG=/sdcard/Documents/yakt/yakt.log
  else
    LOG=/sdcard/Documents/yakt/yakt.log
  fi
fi
LOG=/sdcard/Documents/yakt/yakt.log
TP=/dev/stune/top-app/uclamp.max
DV=/dev/stune
CP=/dev/cpuset
MC=/sys/module/mmc_core
WT=/proc/sys/vm/watermark_boost_factor
KL=/proc/sys/kernel
VM=/proc/sys/vm
S2=/sys/devices/system/cpu/cpufreq/schedutil
MG=/sys/kernel/mm/lru_gen

PS=$(cat /proc/version)
BT=$(getprop ro.boot.bootdevice)

echo "# YAKT v3" > $LOG
echo "# Build Date: 01/07/2022" >> $LOG
echo -e "# Author: @NotZeetaa (Github)\n" >> $LOG
echo "$(date "+%H:%M:%S") * Device: $(getprop ro.product.system.model)" >> $LOG
echo "$(date "+%H:%M:%S") * Kernel: $(uname -r)" >> $LOG
echo -e "$(date "+%H:%M:%S") * Android Version: $(getprop ro.system.build.version.release)\n" >> $LOG

# Use Google's schedutil rate-limits from Pixel 3
# Credits to Kdrag0n
echo "$(date "+%H:%M:%S") * Applying Google's schedutil rate-limits from Pixel 3" >> $LOG
sleep 0.5
if [ -d $S2 ]; then
  echo 500 > $S2/up_rate_limit_us
  echo 20000 > $S2/down_rate_limit_us
  echo -e "$(date "+%H:%M:%S") * Applied Google's schedutil rate-limits from Pixel 3\n" >> $LOG
elif [ -e $SC ]; then
  for cpu in /sys/devices/system/cpu/*/cpufreq/schedutil
  do
    echo 500 > "${cpu}"/up_rate_limit_us
    echo 20000 > "${cpu}"/down_rate_limit_us
  done
  echo -e "$(date "+%H:%M:%S") * Applied Google's schedutil rate-limits from Pixel 3\n" >> $LOG
else
  echo -e "$(date "+%H:%M:%S") * Abort You are not using schedutil governor\n" >> $LOG
fi
  
# (Rewrited) Tweaks to have less Latency
# Credits to RedHat & tytydraco
echo "$(date "+%H:%M:%S") * Tweaking to Reduce Latency " >> $LOG
echo 15000000 > $KL/sched_wakeup_granularity_ns
echo 10000000 > $KL/sched_min_granularity_ns
echo 5000000 > $KL/sched_migration_cost_ns
sleep 0.5
echo -e "$(date "+%H:%M:%S") * Done.\n" >> $LOG

# Kprofiles Tweak
# Credits to cyberknight
echo "$(date "+%H:%M:%S") * Checking if your kernel has Kprofiles support..." >> $LOG
if [ -d $KP ]; then
  echo "$(date "+%H:%M:%S") * Your Kernel Supports Kprofiles" >> $LOG
  echo "$(date "+%H:%M:%S") * Tweaking it..." >> $LOG
  sleep 0.5
  echo -e "$(date "+%H:%M:%S") * Done.\n" >> $LOG
  echo 2 > $KP/parameters/mode
else
  echo -e "$(date "+%H:%M:%S") * Your Kernel doesn't support Kprofiles\n" >> $LOG
fi

# Less Ram Usage
# The stat_interval one, reduces jitter (Credits to kdrag0n)
# Credits to RedHat for dirty_ratio
echo "$(date "+%H:%M:%S") * Applying Ram Tweaks" >> $LOG
sleep 0.5
echo 50 > $VM/vfs_cache_pressure
echo 20 > $VM/stat_interval
echo -e "$(date "+%H:%M:%S") * Applied Ram Tweaks\n" >> $LOG

# Mglru
# Credits to Arter97
echo "$(date "+%H:%M:%S") * Cheking if your kernel has mglru support..." >> $LOG
if [ -d $MG ]; then
  echo "$(date "+%H:%M:%S") * Found it." >> $LOG
  echo "$(date "+%H:%M:%S") * Tweaking it..." >> $LOG
  echo 5000 > $MG/min_ttl_ms
  echo -e "$(date "+%H:%M:%S") * Done.\n" >> $LOG
else
  echo "$(date "+%H:%M:%S") * Your kernel doesn't support mglru :(" >> $LOG
  echo "$(date "+%H:%M:%S") * Aborting it..." >> $LOG
  echo -e "$(date "+%H:%M:%S") * Done.\n" >> $LOG
fi
  

# Set kernel.perf_cpu_time_max_percent to 15
echo "$(date "+%H:%M:%S") * Applying tweak for perf_cpu_time_max_percent" >> $LOG
echo 15 > $KL/perf_cpu_time_max_percent
echo -e "$(date "+%H:%M:%S") * Done.\n" >> $LOG

# Disable some scheduler logs/stats
# Also iostats & reduce latency
# Credits to tytydraco
echo "$(date "+%H:%M:%S") * Disabling some scheduler logs/stats" >> $LOG
if [ -e $KL/sched_schedstats ]; then
  echo 0 > $KL/sched_schedstats
fi
echo off > $KL/printk_devkmsg
for queue in /sys/block/*/queue
do
    echo 0 > "$queue/iostats"
    echo 64 > "$queue/nr_requests"
done
echo -e "$(date "+%H:%M:%S") * Done.\n" >> $LOG

# Disable Timer migration
echo "$(date "+%H:%M:%S") * Disabling Timer Migration" >> $LOG
echo 0 > $KL/timer_migration
echo -e "$(date "+%H:%M:%S") * Done.\n" >> $LOG

# Cgroup Boost
echo "$(date "+%H:%M:%S") * Checking which scheduler your kernel has" >> $LOG
sleep 0.5
if [ -e $TP ]; then
  # Uclamp Tweaks
  # All credits to @darkhz
  echo "$(date "+%H:%M:%S") * You have uclamp scheduler" >> $LOG
  echo "$(date "+%H:%M:%S") * Applying tweaks for it..." >> $LOG
  sleep 0.3
  for ta in $CP/*/top-app
  do
      echo max > "$ta/uclamp.max"
      echo 10 > "$ta/uclamp.min"
      echo 1 > "$ta/uclamp.boosted"
      echo 1 > "$ta/uclamp.latency_sensitive"
  done
  for fd in $CP/*/foreground
  do
      echo 50 > "$fd/uclamp.max"
      echo 0 > "$fd/uclamp.min"
      echo 0 > "$fd/uclamp.boosted"
      echo 0 > "$fd/uclamp.latency_sensitive"
  done
  for bd in $CP/*/background
  do
      echo max > "$bd/uclamp.max"
      echo 20 > "$bd/uclamp.min"
      echo 0 > "$bd/uclamp.boosted"
      echo 0 > "$bd/uclamp.latency_sensitive"
  done
  for sb in $CP/*/system-background
  do
      echo 40 > "$sb/uclamp.max"
      echo 0 > "$sb/uclamp.min"
      echo 0 > "$sb/uclamp.boosted"
      echo 0 > "$sb/uclamp.latency_sensitive"
  done
  sysctl -w kernel.sched_util_clamp_min_rt_default=96
  sysctl -w kernel.sched_util_clamp_min=128
  echo -e "$(date "+%H:%M:%S") * Done,\n" >> $LOG
else
  echo "$(date "+%H:%M:%S") * You have normal cgroup scheduler" >> $LOG
  echo "$(date "+%H:%M:%S") * Applying tweaks for it..." >> $LOG
  sleep 0.3
  chmod 644 $DV/top-app/schedtune.boost
  echo 1 > $DV/top-app/schedtune.boost
  chmod 664 $DV/top-app/schedtune.boost
  echo 0 > $DV/top-app/schedtune.prefer_idle
  echo 0 > $DV/foreground/schedtune.boost
  echo 0 > $DV/background/schedtune.boost
  echo -e "$(date "+%H:%M:%S") * Done.\n" >> $LOG
fi

# Enable ECN negotiation by default
# By kdrag0n
echo 1 > /proc/sys/net/ipv4/tcp_ecn

# Watermark Boost Tweak
echo "$(date "+%H:%M:%S") * Checking if you have watermark boost support" >> $LOG
if [[ "$PS" == *"4.19"* ]]
then
  echo "$(date "+%H:%M:%S") * Found 4.19 kernel, disabling watermark boost because doesn't work..." >> $LOG
  echo 0 > $VM/watermark_boost_factor
  echo -e "$(date "+%H:%M:%S") * Done.\n" >> $LOG
elif [ -e $WT ]; then
  echo "$(date "+%H:%M:%S") * Found Watermark Boost support, tweaking it" >> $LOG
  echo 1500 > $WT
  echo -e "$(date "+%H:%M:%S") * Done.\n" >> $LOG
else
  echo "$(date "+%H:%M:%S") * Your kernel doesn't support watermark boost" >> $LOG
  echo "$(date "+%H:%M:%S") * Aborting it..." >> $LOG
  echo -e "$(date "+%H:%M:%S") * Done.\n" >> $LOG
fi

echo "$(date "+%H:%M:%S") * Tweaking read_ahead overall..." >> $LOG
for queue2 in /sys/block/*/queue/read_ahead_kb
do
echo 128 > $queue2
done
echo -e "$(date "+%H:%M:%S") * Tweaked read_ahead.\n" >> $LOG

# UFSTW (UFS Turbo Write Tweak)
echo "$(date "+%H:%M:%S") * Checking if your kernel has UFS Turbo Write Support" >> $LOG
if [ -e /sys/devices/platform/soc/$BT/ufstw_lu0/tw_enable ]; then
  echo "$(date "+%H:%M:%S") * Your kernel has UFS Turbo Write Support. Tweaking it..." >> $LOG
  echo 1 > /sys/devices/platform/soc/$BT/ufstw_lu0/tw_enable
  echo -e "$(date "+%H:%M:%S") * Done.\n" >> $LOG
else
  echo -e "$(date "+%H:%M:%S") * Your kernel doesn't have UFS Turbo Write Support.\n" >> $LOG
fi

# Extfrag
# Credits to @tytydraco
echo "$(date "+%H:%M:%S") * Increasing fragmentation index..." >> $LOG
echo 750 > $VM/extfrag_threshold
sleep 0.5
echo -e "$(date "+%H:%M:%S") * Done.\n" >> $LOG

# Disable Spi CRC
if [ -d $MC ]; then
  echo "$(date "+%H:%M:%S") * Disabling Spi CRC" >> $LOG
  echo 0 > $MC/parameters/use_spi_crc
  echo -e "$(date "+%H:%M:%S") * Done.\n" >> $LOG
fi

echo "$(date "+%H:%M:%S") * The Tweak is done enjoy :)" >> $LOG
