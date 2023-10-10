#!/system/bin/sh 
 # Yakt v11
 # Author: @NotZeetaa (Github)
 # Contributed: @CRANKV2 (Github)
  # ×××××××××××××××××××××××××× #

#sleep 30
# Function to log normal messages
log-yakt() {
    local message="$1"
    echo "[$(date "+%H:%M:%S")] $message" >> $LOG
}

# Function to log error messages
log-error() {
    local message="$1"
    echo "[$(date "+%H:%M:%S")] $message" >> $ERROR_LOG
}

# Function to write values to files
write() {
    local file="$1"
    local value="$2"

    # Check if the file exists
    if [ ! -f "$file" ]; then
        log-error "Error: File $file does not exist."
        return 1
    fi

    # Make file writable
    chmod +w "$file" 2>/dev/null

    # Write new value, bail out if it fails
    if ! echo "$value" >"$file" 2>/dev/null; then
        log-error "Error: Failed to write to $file."
        return 1
    else
        return 0
    fi
}

# Set the log file paths
if [ ! -d /sdcard/Documents/yakt ]; then
    mkdir -p /sdcard/Documents/yakt
    if [ $? -ne 0 ]; then
        log-error "Error: Unable to create directory /sdcard/Documents/yakt"
        exit 1
    fi
fi

LOG=/sdcard/Documents/yakt/yakt.log
ERROR_LOG=/data/adb/modules/YAKT/yakt-logging-error.log

if [ -f "$LOG" ]; then
    rm "$LOG"
fi

if [ -f "$ERROR_LOG" ]; then
    rm "$ERROR_LOG"
fi

touch "$LOG"
if [ $? -ne 0 ]; then
    log-error "Error: Unable to create log file $LOG"
    exit 1
fi

touch "$ERROR_LOG"
if [ $? -ne 0 ]; then
    log-error "Error: Unable to create error log file $ERROR_LOG"
    exit 1
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


# Start logging error info
log-yakt "Starting YAKT v11"
log-yakt "Build Date: 05/10/2023"
log-yakt "Author: @NotZeetaa (Github)"
log-yakt "Device: $(getprop ro.product.system.model)"
log-yakt "Brand: $(getprop ro.product.system.brand)"
log-yakt "Kernel: $(uname -r)"
log-yakt "Rom build type: $(getprop ro.system.build.type)"
log-yakt "Android Version: $(getprop ro.system.build.version.release)"

# Grouping tasks tweak
log-yakt ""
log-yakt "Enabling Sched Auto Group..."
write "$KL/sched_autogroup_enabled" 1
log-yakt "Done."
log-yakt ""


# Tweak scheduler to have less Latency
log-yakt ""
log-yakt "Tweaking to Reduce Latency"
write "$KL/sched_migration_cost_ns" 5000000
write "$KL/sched_latency_ns" "$SCHED_PERIOD"
write "$KL/sched_nr_migrate" 16
sleep 0.5
log-yakt "Done."
log-yakt ""



# Enable CRF by default
log-yakt ""
log-yakt "Enabling child_runs_first"
write "$KL/sched_child_runs_first" 1
log-yakt "Done."
log-yakt ""


# Ram Tweak
log-yakt ""
log-yakt "Applying Ram Tweaks"
sleep 0.5
write "$VM/vfs_cache_pressure" 40
write "$VM/stat_interval" 15
write "$VM/compaction_proactiveness" 0
write "$VM/page-cluster" 0
write "$VM/swappiness" 100
log-yakt "Applied Ram Tweaks"
log-yakt ""

# Mglru
log-yakt ""
log-yakt "Checking if your kernel has mglru support..."
if [ -d "$MG" ]; then
    log-yakt "Found it."
    log-yakt "Tweaking it..."
    write "$MG/min_ttl_ms" 5000
    log-yakt "Done."
    log-yakt ""
else
    log-yakt "Your kernel doesn't support mglru :("
    log-yakt "Aborting it..."
    log-yakt ""
fi

# Set kernel.perf_cpu_time_max_percent to 40
log-yakt ""
log-yakt "Applying tweak for perf_cpu_time_max_percent"
write "$KL/perf_cpu_time_max_percent" 40
log-yakt "Done."
log-yakt ""

# Disable some scheduler logs/stats
log-yakt ""
log-yakt "Disabling some scheduler logs/stats"
if [ -e "$KL/sched_schedstats" ]; then
    write "$KL/sched_schedstats" 0
fi
write "$KL/printk" "0        0 0 0"
write "$KL/printk_devkmsg" "off"
for queue in /sys/block/*/queue
do
    write "$queue/iostats" 0
    write "$queue/nr_requests" 256
done
log-yakt "Done."
log-yakt ""

# Disable Timer migration
log-yakt ""
log-yakt "Disabling Timer Migration"
write "$KL/timer_migration" 0
log-yakt "Done."
log-yakt ""

# Cgroup Tweak
sleep 0.5
if [ -e "$TP" ]; then
    # Uclamp Tweak
    log-yakt ""
    log-yakt "You have uclamp scheduler"
    log-yakt "Applying tweaks for it..."
    sleep 0.3
    for ta in "$CP"/top-app
    do
        write "$ta/uclamp.max" max
        write "$ta/uclamp.min" 10
        write "$ta/uclamp.boosted" 1
        write "$ta/uclamp.latency_sensitive" 1
    done
    for fd in "$CP"/foreground
    do
        write "$fd/uclamp.max" 50
        write "$fd/uclamp.min" 0
        write "$fd/uclamp.boosted" 0
        write "$fd/uclamp.latency_sensitive" 0
    done
    for bd in "$CP"/background
    do
        write "$bd/uclamp.max" max
        write "$bd/uclamp.min" 20
        write "$bd/uclamp.boosted" 0
        write "$bd/uclamp.latency_sensitive" 0
    done
    for sb in "$CP"/system-background
    do
        write "$sb/uclamp.max" 40
        write "$sb/uclamp.min" 0
        write "$sb/uclamp.boosted" 0
        write "$sb/uclamp.latency_sensitive" 0
    done
    sysctl -w kernel.sched_util_clamp_min_rt_default=0
    sysctl -w kernel.sched_util_clamp_min=128
    log-yakt "Done,"
    log-yakt ""
fi

# Enable ECN negotiation by default
log-yakt ""
log-yakt "Enabling ECN negotiation..."
write "/proc/sys/net/ipv4/tcp_ecn" 1
log-yakt "Done."
log-yakt ""

# Always allow sched boosting on top-app tasks
log-yakt ""
log-yakt "Always allow sched boosting on top-app tasks"
write "$KL/sched_min_task_util_for_colocation" 0
log-yakt "Done."
log-yakt ""


# Watermark Boost Tweak
if [ -e "$WT" ]; then
    log-yakt ""
    log-yakt "Disabling watermark boost..."
    write "$VM/watermark_boost_factor" 0
    log-yakt "Done."
    log-yakt ""
fi

log-yakt ""
log-yakt "Tweaking read_ahead overall..."
for queue2 in /sys/block/*/queue/read_ahead_kb
do
    write "$queue2" 128
done
log-yakt "Tweaked read_ahead."
log-yakt ""

# UFSTW (UFS Turbo Write Tweak)
log-yakt ""
log-yakt "Checking if your kernel has UFS Turbo Write Support"
if [ -e "/sys/devices/platform/soc/$BT/ufstw_lu0/tw_enable" ]; then
    log-yakt "Your kernel has UFS Turbo Write Support. Tweaking it..."
    write "/sys/devices/platform/soc/$BT/ufstw_lu0/tw_enable" 1
    log-yakt "Done."
    log-yakt ""
else
    log-yakt "Your kernel doesn't have UFS Turbo Write Support."
    log-yakt ""
fi

# Extfrag
log-yakt ""
log-yakt "Increasing fragmentation index..."
write "$VM/extfrag_threshold" 750
sleep 0.5
log-yakt "Done."
log-yakt ""

# Disable Spi CRC
if [ -d "$ML/mmc_core" ]; then
    log-yakt ""
    log-yakt "Disabling Spi CRC"
    write "$ML/mmc_core/parameters/use_spi_crc" 0
    log-yakt "Done."
    log-yakt ""
fi

# Zswap Tweak
log-yakt ""
log-yakt "Checking if your kernel supports zswap.."
if [ -d "$ML/zswap" ]; then
    log-yakt "Your kernel supports zswap, tweaking it.."
    write "$ML/zswap/parameters/compressor" lz4
    log-yakt "Set your zswap compressor to lz4 (Fastest compressor)."
    write "$ML/zswap/parameters/zpool" zsmalloc
    log-yakt "Set your zpool compressor to zsmalloc."
    log-yakt "Tweaked!"
    log-yakt ""
else
    log-yakt "Your kernel doesn't support zswap, aborting it..."
    log-yakt ""
fi

# Enable Power Efficient
log-yakt ""
log-yakt "Enabling Power Efficient..."
write "$ML/workqueue/parameters/power_efficient" 1
log-yakt "Done."
log-yakt ""
log-yakt ""

log-yakt "The Tweak is done enjoy :)"
