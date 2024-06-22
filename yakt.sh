#!/system/bin/sh
# YAKT v18
# Author: @NotZeetaa (Github)
# This script applies various performance and battery optimizations to Android devices.

# Wait for the system to stabilize before applying tweaks
sleep 30

# Function to append a message to the specified log file
log_message() {
    local log_file="$1"
    local message="$2"
    echo "[$(date "+%H:%M:%S")] $message" >> "$log_file"
}

# Function to log info messages
log_info() {
    log_message "$INFO_LOG" "$1"
}

# Function to log error messages
log_error() {
    log_message "$ERROR_LOG" "$1"
}

# Function to write a value to a specified file
write_value() {
    local file_path="$1"
    local value="$2"

    # Check if the file exists and is writable
    if [ -w "$file_path" ]; then
        echo "$value" > "$file_path" 2>/dev/null
        log_info "Successfully wrote $value to $file_path"
    else
        log_error "Error: Cannot write to $file_path."
    fi
}

# Get the directory of this script
MODDIR=${0%/*}

# Define log file paths
INFO_LOG="${MODDIR}/info.log"
ERROR_LOG="${MODDIR}/error.log"

# Prepare log files by clearing their content
:> "$INFO_LOG"
:> "$ERROR_LOG"

# Variables for paths and system information
UCLAMP_PATH="/dev/stune/top-app/uclamp.max"
CPUSET_PATH="/dev/cpuset"
MODULE_PATH="/sys/module"
KERNEL_PATH="/proc/sys/kernel"
MEMORY_PATH="/proc/sys/vm"
MGLRU_PATH="/sys/kernel/mm/lru_gen"
SCHEDUTIL_PATH="/sys/devices/system/cpu/cpu*/cpufreq/schedutil"
ANDROID_VERSION=$(getprop ro.build.version.release)
TOTAL_RAM=$(free -m | awk '/Mem/{print $2}')

# Log starting information
log_info "Starting YAKT v18"
log_info "Build Date: $(date "+%d/%m/%Y")"
log_info "Author: @NotZeetaa (Github)"
log_info "Device: $(getprop ro.product.system.model)"
log_info "Brand: $(getprop ro.product.system.brand)"
log_info "Kernel: $(uname -r)"
log_info "ROM Build Type: $(getprop ro.system.build.type)"
log_info "Android Version: $ANDROID_VERSION"
log_info "Total RAM: ${TOTAL_RAM}MB"

# Apply schedutil rate-limits tweak
log_info "Applying schedutil rate-limits tweak"
if [ -d "$SCHEDUTIL_PATH" ]; then
    for cpu in $SCHEDUTIL_PATH; do
        write_value "${cpu}/up_rate_limit_us" 10000
        write_value "${cpu}/down_rate_limit_us" 20000
    done
    log_info "Applied schedutil rate-limits tweak to all CPUs"
else
    log_info "Abort: Not using schedutil governor"
fi

# Disable Sched Auto Group
log_info "Disabling Sched Auto Group"
write_value "$KERNEL_PATH/sched_autogroup_enabled" 0
log_info "Sched Auto Group disabled"

# Enable CRF by default
log_info "Enabling child_runs_first"
write_value "$KERNEL_PATH/sched_child_runs_first" 1
log_info "child_runs_first enabled"

# Apply RAM tweaks
log_info "Applying RAM tweaks"
write_value "$MEMORY_PATH/vfs_cache_pressure" 50
write_value "$MEMORY_PATH/stat_interval" 30
write_value "$MEMORY_PATH/compaction_proactiveness" 0
write_value "$MEMORY_PATH/page-cluster" 0
log_info "Applied RAM tweaks"

# Adjust swappiness based on total RAM
log_info "Detecting if your device has less or more than 8GB of RAM"
if [ $TOTAL_RAM -lt 8000 ]; then
    log_info "Detected 8GB or less of RAM"
    write_value "$MEMORY_PATH/swappiness" 60
else
    log_info "Detected more than 8GB of RAM"
    write_value "$MEMORY_PATH/swappiness" 0
fi
write_value "$MEMORY_PATH/dirty_ratio" 60

# MGLRU tweaks
log_info "Checking if your kernel has MGLRU support"
if [ -d "$MGLRU_PATH" ]; then
    log_info "MGLRU support found, applying tweaks"
    write_value "$MGLRU_PATH/min_ttl_ms" 5000
    log_info "MGLRU tweaks applied"
else
    log_info "MGLRU support not found, aborting MGLRU tweaks"
fi

# Set kernel.perf_cpu_time_max_percent to 10
log_info "Setting perf_cpu_time_max_percent to 10"
write_value "$KERNEL_PATH/perf_cpu_time_max_percent" 10
log_info "Applied kernel.perf_cpu_time_max_percent value"

# Disable certain scheduler logs/stats
log_info "Disabling some scheduler logs/stats"
write_value "$KERNEL_PATH/sched_schedstats" 0
write_value "$KERNEL_PATH/printk" "0 0 0 0"
write_value "$KERNEL_PATH/printk_devkmsg" "off"
for queue in /sys/block/*/queue; do
    write_value "$queue/iostats" 0
    write_value "$queue/nr_requests" 64
done
log_info "Scheduler logs/stats disabled"

# Tweak scheduler to have less latency
log_info "Tweaking scheduler to reduce latency"
write_value "$KERNEL_PATH/sched_migration_cost_ns" 50000
write_value "$KERNEL_PATH/sched_min_granularity_ns" 1000000
write_value "$KERNEL_PATH/sched_wakeup_granularity_ns" 1500000
log_info "Scheduler latency reduced"

# Disable Timer migration
log_info "Disabling Timer Migration"
write_value "$KERNEL_PATH/timer_migration" 0
log_info "Timer Migration disabled"

# Cgroup tweak for UCLAMP scheduler
if [ -e "$UCLAMP_PATH" ]; then
    log_info "UCLAMP scheduler detected, applying tweaks"
    write_value "${CPUSET_PATH}/top-app/uclamp.max" max
    write_value "${CPUSET_PATH}/top-app/uclamp.min" 10
    write_value "${CPUSET_PATH}/top-app/uclamp.boosted" 1
    write_value "${CPUSET_PATH}/top-app/uclamp.latency_sensitive" 1

    write_value "${CPUSET_PATH}/foreground/uclamp.max" 50
    write_value "${CPUSET_PATH}/foreground/uclamp.min" 0
    write_value "${CPUSET_PATH}/foreground/uclamp.boosted" 0
    write_value "${CPUSET_PATH}/foreground/uclamp.latency_sensitive" 0

    write_value "${CPUSET_PATH}/background/uclamp.max" max
    write_value "${CPUSET_PATH}/background/uclamp.min" 20
    write_value "${CPUSET_PATH}/background/uclamp.boosted" 0
    write_value "${CPUSET_PATH}/background/uclamp.latency_sensitive" 0

    write_value "${CPUSET_PATH}/system-background/uclamp.max" 40
    write_value "${CPUSET_PATH}/system-background/uclamp.min" 0
    write_value "${CPUSET_PATH}/system-background/uclamp.boosted" 0
    write_value "${CPUSET_PATH}/system-background/uclamp.latency_sensitive" 0

    sysctl -w kernel.sched_util_clamp_min_rt_default=0
    sysctl -w kernel.sched_util_clamp_min=128
    log_info "Applied UCLAMP scheduler tweaks"
else
    log_info "UCLAMP scheduler not detected, skipping tweaks"
fi

# Always allow sched boosting on top-app tasks
log_info "Always allow sched boosting on top-app tasks"
write_value "$KERNEL_PATH/sched_min_task_util_for_colocation" 0

# Disable SPI CRC if supported
log_info "Checking for SPI CRC support"
if [ -d "$MODULE_PATH/mmc_core" ]; then
    log_info "SPI CRC supported, disabling it"
    write_value "$MODULE_PATH/mmc_core/parameters/use_spi_crc" 0
else
    log_info "SPI CRC not supported, skipping"
fi

# Enable LZ4 for zRAM
log_info "Enabling LZ4 for zRAM"
for zram_dir in /sys/block/zram*; do
    write_value "$zram_dir/comp_algorithm" lz4
    write_value "$zram_dir/max_comp_streams" 4
done
log_info "Applied LZ4 compression to zRAM"

# Disable kernel panic for hung_task
log_info "Disabling kernel panic for hung_task"
write_value "$KERNEL_PATH/panic_on_oops" 0
write_value "$KERNEL_PATH/hung_task_panic" 0
write_value "$KERNEL_PATH/hung_task_timeout_secs" 0
log_info "Kernel panic disabled for hung_task"

# ZSwap tweaks
log_info "Checking for zswap support"
if [ -d "$MODULE_PATH/zswap" ]; then
    log_info "zswap supported, applying tweaks"
    write_value "$MODULE_PATH/zswap/parameters/compressor" lz4
    write_value "$MODULE_PATH/zswap/parameters/zpool" zsmalloc
    log_info "Applied zswap tweaks"
else
    log_info "Your kernel doesn't support zswap, aborting"
fi

# Enable power efficiency
log_info "Enabling power efficiency"
write_value "$MODULE_PATH/workqueue/parameters/power_efficient" 1
log_info "Power efficiency enabled"

# Network Tweaks
log_info "Applying network tweaks"
write_value "/proc/sys/net/ipv4/tcp_fastopen" 3
write_value "/proc/sys/net/ipv4/tcp_slow_start_after_idle" 0
write_value "/proc/sys/net/ipv4/tcp_mtu_probing" 1
write_value "/proc/sys/net/ipv4/tcp_ecn" 1
write_value "/proc/sys/net/ipv4/tcp_window_scaling" 1
write_value "/proc/sys/net/ipv4/tcp_keepalive_time" 1200
write_value "/proc/sys/net/ipv4/tcp_keepalive_intvl" 30
write_value "/proc/sys/net/ipv4/tcp_keepalive_probes" 5
write_value "/proc/sys/net/ipv4/tcp_sack" 1
write_value "/proc/sys/net/core/wmem_max" 8388608
write_value "/proc/sys/net/core/rmem_max" 8388608
write_value "/proc/sys/net/ipv4/tcp_rmem" "4096 87380 8388608"
write_value "/proc/sys/net/ipv4/tcp_wmem" "4096 65536 8388608"
write_value "/proc/sys/net/ipv4/tcp_timestamps" 0
write_value "/proc/sys/net/ipv4/tcp_low_latency" 1
log_info "Network tweaks applied"

# GPU Tweaks
log_info "Applying GPU tweaks"
GPU_PATH="/sys/class/kgsl/kgsl-3d0"
if [ -d "$GPU_PATH" ]; then
    write_value "$GPU_PATH/default_pwrlevel" 6
    write_value "$GPU_PATH/force_clk_on" 1
    write_value "$GPU_PATH/max_pwrlevel" 6
    write_value "$GPU_PATH/min_pwrlevel" 6
    log_info "Applied GPU tweaks"
else
    log_info "GPU path not found, skipping GPU tweaks"
fi

# I/O Scheduler Tweaks
log_info "Applying I/O scheduler tweaks"
for queue in /sys/block/*/queue; do
    write_value "$queue/scheduler" "noop"
    write_value "$queue/add_random" 0
    write_value "$queue/nomerges" 2
    write_value "$queue/rotational" 0
    write_value "$queue/rq_affinity" 2
done
log_info "Applied I/O scheduler tweaks"

# CPU Idle and Frequency Tweaks
log_info "Applying CPU idle and frequency tweaks"
CPUFREQ_PATH="/sys/devices/system/cpu/cpu0/cpufreq"
if [ -d "$CPUFREQ_PATH" ]; then
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
        write_value "${cpu}/scaling_governor" "schedutil"
        write_value "${cpu}/schedutil/up_rate_limit_us" 10000
        write_value "${cpu}/schedutil/down_rate_limit_us" 20000
        write_value "${cpu}/scaling_min_freq" "$(cat ${cpu}/cpuinfo_min_freq)"
        write_value "${cpu}/scaling_max_freq" "$(cat ${cpu}/cpuinfo_max_freq)"
    done
    log_info "Applied CPU frequency tweaks"
else
    log_info "CPU frequency path not found, skipping CPU frequency tweaks"
fi

# Filesystem Tweaks
log_info "Applying filesystem tweaks"
write_value "/proc/sys/fs/lease-break-time" 10
write_value "/proc/sys/fs/file-max" 2097152
log_info "Applied filesystem tweaks"

# Miscellaneous Tweaks
log_info "Applying miscellaneous tweaks"
write_value "/proc/sys/kernel/random/read_wakeup_threshold" 256
write_value "/proc/sys/kernel/random/write_wakeup_threshold" 256
log_info "Applied miscellaneous tweaks"

# Disable Debugging for Power Saving
log_info "Disabling various debug features for power saving"
write_value "/sys/module/kernel/parameters/initcall_debug" 0
write_value "/sys/module/printk/parameters/time" 0
write_value "/sys/module/printk/parameters/debug" 0
log_info "Disabled various debug features"

# Finished applying all tweaks
log_info "YAKT tweaks applied successfully"
