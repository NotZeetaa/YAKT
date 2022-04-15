#!/system/bin/sh
MODDIR=${0%/*}
while [[ "$(getprop sys.boot_completed)" -ne 1 ]] && [[ ! -d "/sdcard" ]]
do
       sleep 5
done

sleep 30
$MODDIR/script/zeetaatweaks.sh > /dev/null
