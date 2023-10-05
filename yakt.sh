#!/system/bin/sh
# Yakt v10
# Author: @NotZeetaa (Github)
# ×××××××××××××××××××××××××× #

sleep 30
# Log create
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

# Variables
TP=/dev/stune/top-app/uclamp.max
CP=/dev/cpuset
ML=/sys/module
WT=/proc/sys/vm/watermark_boost_factor
KL=/proc/sys/kernel
VM=/proc/sys/vm
MG=/sys/kernel/mm/lru_gen
BT=$(getprop ro.boot.bootdevice)
BL=/dev/blkio
SCHED_PERIOD="$((1 * 1000 * 1000))"

# Info
echo "# YAKT v10" > $LOG
echo "# Build Date: 27/08/2023" >> $LOG
echo -e "# Author: @NotZeetaa (Github)\n" >> $LOG
echo "[$(date "+%H:%M:%S")] Device: $(getprop ro.product.system.model)" >> $LOG
echo "[$(date "+%H:%M:%S")] Brand: $(getprop ro.product.system.brand)" >> $LOG
echo "[$(date "+%H:%M:%S")] Kernel: $(uname -r)" >> $LOG
echo "[$(date "+%H:%M:%S")] Rom build type: $(getprop ro.system.build.type)" >> $LOG
echo -e "[$(date "+%H:%M:%S")] Android Version: $(getprop ro.system.build.version.release)\n" >> $LOG

# Grouping tasks tweak
echo "[$(date "+%H:%M:%S")] Enabling Sched Auto Group..." >> $LOG
echo 1 > $KL/sched_autogroup_enabled
echo -e "[$(date "+%H:%M:%S")] Done.\n" >> $LOG

# Tweak scheduler to have less Latency
# Credits to RedHat & tytydraco & KTweak
echo "[$(date "+%H:%M:%S")] Tweaking to Reduce Latency " >> $LOG
echo 5000000 > $KL/sched_migration_cost_ns
echo "$SCHED_PERIOD" > $KL/sched_latency_ns
echo 16 > $KL/sched_nr_migrate
sleep 0.5
echo -e "[$(date "+%H:%M:%S")] Done.\n" >> $LOG

# Ram Tweak
# The stat_interval one reduces jitter (Credits to kdrag0n)
# Credits to RedHat for dirty_ratio
echo "[$(date "+%H:%M:%S")] Applying Ram Tweaks" >> $LOG
sleep 0.5
echo 40 > $VM/vfs_cache_pressure
echo 15 > $VM/stat_interval
echo 0 > $VM/compaction_proactiveness
echo 0 > $VM/page-cluster
echo 100 > $VM/swappiness
echo -e "[$(date "+%H:%M:%S")] Applied Ram Tweaks\n" >> $LOG

# Mglru
# Credits to Arter97
echo "[$(date "+%H:%M:%S")] Cheking if your kernel has mglru support..." >> $LOG
if [ -d $MG ]; then
    echo "[$(date "+%H:%M:%S")] Found it." >> $LOG
    echo "[$(date "+%H:%M:%S")] Tweaking it..." >> $LOG
    echo 5000 > $MG/min_ttl_ms
    echo -e "[$(date "+%H:%M:%S")] Done.\n" >> $LOG
else
    echo "[$(date "+%H:%M:%S")] Your kernel doesn't support mglru :(" >> $LOG
    echo "[$(date "+%H:%M:%S")] Aborting it..." >> $LOG
    echo -e "[$(date "+%H:%M:%S")] Done.\n" >> $LOG
fi

# Set kernel.perf_cpu_time_max_percent to 40
echo "[$(date "+%H:%M:%S")] Applying tweak for perf_cpu_time_max_percent" >> $LOG
echo 40 > $KL/perf_cpu_time_max_percent
echo -e "[$(date "+%H:%M:%S")] Done.\n" >> $LOG

# Disable some scheduler logs/stats
# Also iostats & reduce latency
# Credits to tytydraco
echo "[$(date "+%H:%M:%S")] Disabling some scheduler logs/stats" >> $LOG
if [ -e $KL/sched_schedstats ]; then
    echo 0 > $KL/sched_schedstats
fi
echo "0	0 0 0" > $KL/printk
echo off > $KL/printk_devkmsg
for queue in /sys/block/*/queue
do
    echo 0 > "$queue/iostats"
    echo 256 > "$queue/nr_requests"
done
echo -e "[$(date "+%H:%M:%S")] Done.\n" >> $LOG

# Disable Timer migration
echo "[$(date "+%H:%M:%S")] Disabling Timer Migration" >> $LOG
echo 0 > $KL/timer_migration
echo -e "[$(date "+%H:%M:%S")] Done.\n" >> $LOG

# Cgroup Tweak
sleep 0.5
if [ -e $TP ]; then
    # Uclamp Tweak
    # All credits to @darkhz
    echo "[$(date "+%H:%M:%S")] You have uclamp scheduler" >> $LOG
    echo "[$(date "+%H:%M:%S")] Applying tweaks for it..." >> $LOG
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
    sysctl -w kernel.sched_util_clamp_min_rt_default=0
    sysctl -w kernel.sched_util_clamp_min=128
    echo -e "[$(date "+%H:%M:%S")] Done,\n" >> $LOG
fi

# Enable ECN negotiation by default
# By kdrag0n
echo "[$(date "+%H:%M:%S")] Enabling ECN negotiation..." >> $LOG
echo 1 > /proc/sys/net/ipv4/tcp_ecn
echo -e "[$(date "+%H:%M:%S")] Done.\n" >> $LOG

# Always allow sched boosting on top-app tasks
# Credits to tytydraco
echo "[$(date "+%H:%M:%S")] Always allow sched boosting on top-app tasks" >> $LOG
echo 0 > $KL/sched_min_task_util_for_colocation
echo -e "[$(date "+%H:%M:%S")] Done.\n" >> $LOG

# Watermark Boost Tweak
if [ -e $WT ]; then
    echo "[$(date "+%H:%M:%S")] Disabling watermark boost..." >> $LOG
    echo 0 > $VM/watermark_boost_factor
    echo -e "[$(date "+%H:%M:%S")] Done.\n" >> $LOG
fi

echo "[$(date "+%H:%M:%S")] Tweaking read_ahead overall..." >> $LOG
for queue2 in /sys/block/*/queue/read_ahead_kb
do
echo 128 > $queue2
done
echo -e "[$(date "+%H:%M:%S")] Tweaked read_ahead.\n" >> $LOG

# UFSTW (UFS Turbo Write Tweak)
echo "[$(date "+%H:%M:%S")] Checking if your kernel has UFS Turbo Write Support" >> $LOG
if [ -e /sys/devices/platform/soc/$BT/ufstw_lu0/tw_enable ]; then
    echo "[$(date "+%H:%M:%S")] Your kernel has UFS Turbo Write Support. Tweaking it..." >> $LOG
    echo 1 > /sys/devices/platform/soc/$BT/ufstw_lu0/tw_enable
    echo -e "[$(date "+%H:%M:%S")] Done.\n" >> $LOG
else
    echo -e "[$(date "+%H:%M:%S")] Your kernel doesn't have UFS Turbo Write Support.\n" >> $LOG
fi

# Extfrag
# Credits to @tytydraco
echo "[$(date "+%H:%M:%S")] Increasing fragmentation index..." >> $LOG
echo 750 > $VM/extfrag_threshold
sleep 0.5
echo -e "[$(date "+%H:%M:%S")] Done.\n" >> $LOG

# Disable Spi CRC
if [ -d $ML/mmc_core ]; then
    echo "[$(date "+%H:%M:%S")] Disabling Spi CRC" >> $LOG
    echo 0 > $ML/mmc_core/parameters/use_spi_crc
    echo -e "[$(date "+%H:%M:%S")] Done.\n" >> $LOG
fi

# Zswap Tweak
echo "[$(date "+%H:%M:%S")] Checking if your kernel supports zswap.." >> $LOG
if [ -d $ML/zswap ]; then
    echo "[$(date "+%H:%M:%S")] Your kernel supports zswap, tweaking it.." >> $LOG
    echo lz4 > $ML/zswap/parameters/compressor
    echo "[$(date "+%H:%M:%S")] Setted your zswap compressor to lz4 (Fastest compressor)." >> $LOG
    echo zsmalloc > $ML/zswap/parameters/zpool
    echo -e "[$(date "+%H:%M:%S")] Setted your zpool compressor to zsmalloc." >> $LOG
    echo -e "[$(date "+%H:%M:%S")] Tweaked!\n" >> $LOG
else
    echo -e "[$(date "+%H:%M:%S")] Your kernel doesn't support zswap, aborting it...\n" >> $LOG
fi

# Enable Power Efficient
echo "[$(date "+%H:%M:%S")] Enabling Power Efficient..." >> $LOG
echo 1 > $ML/workqueue/parameters/power_efficient
echo -e "[$(date "+%H:%M:%S")] Done.\n" >> $LOG

echo "[$(date "+%H:%M:%S")] The Tweak is done enjoy :)" >> $LOG
