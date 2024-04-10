#!/system/bin/sh
# Yakt v15
# Author: @NotZeetaa (Github)
# ×××××××××××××××××××××××××× #

sleep 30
# Function to append a message to the specified log file
_log_yakt() {
    # shellcheck disable=SC3043
    local log="$1"
    # shellcheck disable=SC3043
    local message="$2"
    echo "[$(date "+%H:%M:%S")] $message" >> "$log"
}

# Function to log info messages
log_info() {
    _log_yakt "$INFO_LOG" "$1"
}

# Function to log error messages
log_error() {
    _log_yakt "$ERROR_LOG" "$1"
}

# useful for debugging ig ¯\_(ツ)_/¯
# shellcheck disable=SC3033
# log_debug() {
#     _log_yakt "$DEBUG_LOG" "$1"
# }

write() {
    # shellcheck disable=SC3043
    local file="$1"
    # shellcheck disable=SC3043
    local value="$2"

    # Check if the file exists
    if [ ! -f "$file" ]; then
        log_error "Error: File $file does not exist."
        return 1
    fi

    # Make file writable
    chmod +w "$file" 2>/dev/null

    # Write new value, bail out if it fails
    if ! echo "$value" >"$file" 2>/dev/null; then
        log_error "Error: Failed to write to $file."
        return 1
    else
        return 0
    fi
}

MODDIR=${0%/*} # get parent directory

# Modify the filenames for logs
INFO_LOG="${MODDIR}/info.log"
ERROR_LOG="${MODDIR}/error.log"
# DEBUG_LOG="${MODDIR}/debug.log"

# prepare log files
:> "$INFO_LOG"
:> "$ERROR_LOG"
# :> "$DEBUG_LOG"

# Variables
UCLAMP=/dev/stune/top-app/uclamp.max
CPUSET=/dev/cpuset
MODULE=/sys/module
KERNEL=/proc/sys/kernel
MEMORY=/proc/sys/vm
MGLRU=/sys/kernel/mm/lru_gen
SCHEDUTIL2=/sys/devices/system/cpu/cpufreq/schedutil
SCHEDUTIL=/sys/devices/system/cpu/cpu0/cpufreq/schedutil
ANDROID_VERSION=$(getprop ro.build.version.release)
TOTAL_RAM=$(free -m | awk '/Mem/{print $2}')

# Info
log_info "Starting YAKT v15"
log_info "Build Date: 26/02/2024"
log_info "Author: @NotZeetaa (Github)"
log_info "Device: $(getprop ro.product.system.model)"
log_info "Brand: $(getprop ro.product.system.brand)"
log_info "Kernel: $(uname -r)"
log_info "Rom build type: $(getprop ro.system.build.type)"
log_info "Android Version: $ANDROID_VERSION"

# Use Google's schedutil rate-limits from Pixel 3
# Credits to Kdrag0n
log_info "Applying Google's schedutil rate-limits from Pixel 3"
if [ -d $SCHEDUTIL2 ]; then
    write "$SCHEDUTIL2/up_rate_limit_us" 500
    write "$SCHEDUTIL2/down_rate_limit_us" 20000
    log_info "Applied Google's schedutil rate-limits from Pixel 3"
elif [ -e $SCHEDUTIL ]; then
    for cpu in /sys/devices/system/cpu/*/cpufreq/schedutil
    do
        write "${cpu}/up_rate_limit_us" 500
        write "${cpu}/down_rate_limit_us" 20000
    done
    log_info "Applied Google's schedutil rate-limits from Pixel 3"
else
    log_info "Abort You are not using schedutil governor"
fi
log_info ""

# Grouping tasks tweak
log_info ""
log_info "Disabling Sched Auto Group..."
write "$KERNEL/sched_autogroup_enabled" 0
log_info "Done."
log_info ""

# Disable CRF by default
log_info "Enabling child_runs_first"
write "$KERNEL/sched_child_runs_first" 0
log_info "Done."
log_info ""

# Ram Tweak
# The stat_interval one reduces jitter (Credits to kdrag0n)
# Credits to RedHat for dirty_ratio
log_info "Applying Ram Tweaks"
write "$MEMORY/vfs_cache_pressure" 50
write "$MEMORY/stat_interval" 30
write "$MEMORY/compaction_proactiveness" 0
write "$MEMORY/page-cluster" 0
log_info "Detecting if your device has less/higher than 8GB of RAM"
if [ $TOTAL_RAM -lt 8000 ]; then
    log_info "Detected equal or less"
    log_info "Aplying tweaks for it..."
    write "$MEMORY/swappiness" 100
else
    log_info "Detected higher or equal"
    log_info "Aplying tweaks for it..."
    write "$MEMORY/swappiness" 0
fi
write "$MEMORY/dirty_ratio" 60
log_info "Applied Ram Tweaks"
log_info ""

# Mglru
# Credits to Arter97
log_info "Checking if your kernel has mglru support..."
if [ -d "$MGLRU" ]; then
    log_info "Found it."
    log_info "Tweaking it..."
    write "$MGLRU/min_ttl_ms" 5000
    log_info "Done."
    log_info ""
else
    log_info "Your kernel doesn't support mglru :("
    log_info "Aborting it..."
    log_info ""
fi

# Set kernel.perf_cpu_time_max_percent to 10
log_info "Applying tweak for perf_cpu_time_max_percent"
write "$KERNEL/perf_cpu_time_max_percent" 10
log_info "Done."
log_info ""

# Disable some scheduler logs/stats
# Also iostats & reduce latency
# Credits to tytydraco
log_info "Disabling some scheduler logs/stats"
if [ -e "$KERNEL/sched_schedstats" ]; then
    write "$KERNEL/sched_schedstats" 0
fi
write "$KERNEL/printk" "0        0 0 0"
write "$KERNEL/printk_devkmsg" "off"
for queue in /sys/block/*/queue
do
    write "$queue/iostats" 0
    write "$queue/nr_requests" 64
done
log_info "Done."
log_info ""

# Disable Timer migration
log_info "Disabling Timer Migration"
write "$KERNEL/timer_migration" 0
log_info "Done."
log_info ""

# Cgroup Tweak
if [ -e "$UCLAMP" ]; then
    # Uclamp Tweak
    # All credits to @darkhz
    log_info ""
    log_info "You have uclamp scheduler"
    log_info "Applying tweaks for it..."
    ta="${CPUSET}/top-app"
    write "$ta/uclamp.max" max
    write "$ta/uclamp.min" 10
    write "$ta/uclamp.boosted" 1
    write "$ta/uclamp.latency_sensitive" 1
    fd="${CPUSET}/foreground"
    write "$fd/uclamp.max" 50
    write "$fd/uclamp.min" 0
    write "$fd/uclamp.boosted" 0
    write "$fd/uclamp.latency_sensitive" 0
    bd="$CPUSET"/background
    write "$bd/uclamp.max" max
    write "$bd/uclamp.min" 20
    write "$bd/uclamp.boosted" 0
    write "$bd/uclamp.latency_sensitive" 0
    sb="${CPUSET}/system-background"
    write "$sb/uclamp.min" 0
    write "$sb/uclamp.max" 40
    write "$sb/uclamp.boosted" 0
    write "$sb/uclamp.latency_sensitive" 0
    sysctl -w kernel.sched_util_clamp_min_rt_default=0
    sysctl -w kernel.sched_util_clamp_min=128
    log_info "Done,"
    log_info ""
fi

# Always allow sched boosting on top-app tasks
# Credits to tytydraco
log_info "Always allow sched boosting on top-app tasks"
write "$KERNEL/sched_min_task_util_for_colocation" 0
log_info "Done."
log_info ""

# Disable Spi CRC
if [ -d "$MODULE/mmc_core" ]; then
    log_info "Disabling Spi CRC"
    write "$MODULE/mmc_core/parameters/use_spi_crc" 0
    log_info "Done."
    log_info ""
fi

# Zswap Tweak
log_info "Checking if your kernel supports zswap.."
if [ -d "$MODULE/zswap" ]; then
    log_info "Your kernel supports zswap, tweaking it.."
    write "$MODULE/zswap/parameters/compressor" lz4
    log_info "Set your zswap compressor to lz4 (Fastest compressor)."
    write "$MODULE/zswap/parameters/zpool" zsmalloc
    log_info "Set your zpool compressor to zsmalloc."
    log_info "Tweaked!"
    log_info ""
else
    log_info "Your kernel doesn't support zswap, aborting it..."
    log_info ""
fi

# Enable Power Efficient
log_info "Enabling Power Efficient..."
write "$MODULE/workqueue/parameters/power_efficient" 1
log_info "Done."
log_info ""

# Disable phantom process monitoring
log_info "Checking if your Android version is greater than or equal to Android version 12 to disable phantom process monitoring."
if [ "$ANDROID_VERSION" -ge 12 ]; then
    log_info "Android version 12 or higher detected."
    log_info "Disabling phantom process monitoring."
    setprop sys.fflag.override.settings_enable_monitor_phantom_procs false
else
    log_info "Android version 12 or higher not detected."
    log_info "Aborting."
fi
log_info "Done."

log_info "The Tweak is done enjoy :)"
