#!/system/bin/sh
# ZeetaaTweaks V1.1
# By @NotZeetaa (Github)

sleep 60

P=/data/adb/modules/ZeetaaTweaks/script/zts_performance.sh
N=/data/adb/modules/ZeetaaTweaks/script/zts_normal.sh
LOG=/sdcard/ZeetaaTweaksMode.log

echo "# ZeetaaTweaks V1.1" > $LOG
echo "# Build Date: 05/03/2022" >> $LOG
echo "# By @NotZeetaa (Github)" >> $LOG
echo " " >> $LOG
echo "$(date "+%H:%M:%S") * Device: $(getprop ro.product.system.model)" >> $LOG
echo "$(date "+%H:%M:%S") * Kernel: $(uname -r)" >> $LOG
echo "$(date "+%H:%M:%S") * Android Version: $(getprop ro.system.build.version.release)" >> $LOG

# Begin of AI
# Thx to @wHo_EM_i for his top script

while true; do
    sleep 10
     if [ $(su -c top -n 1 -d 1 | head -n 34 | grep -o -e 'skynet' -e 'cputhrottlingtest' -e 'ea.gp' -e 'androbench2' -e 'com.andromeda.androbench2' -e 'andromeda' -e 'antutu' -e 'geekbench5' -e 'primatelabs' -e 'codm' -e 'legends' -e 'nexon' -e 'ea.game' -e 'konami' -e 'bandainamco' -e 'netmarble' -e 'edengames' -e 'tencent' -e 'moonton' -e 'gameloft' -e 'netease' -e 'garena' -e 'pubg' -e 'pubgmhd' -e 'pubgmobile' -e 'miHoYo' -e 'GoogleCamera' -e 'mojang' -e 'AntutuBenchmark' -e 'kinemasterfree' -e 'alightcreative' -e 'aethersx2' -e 'criticalops' -e 'supercell' -e 'warface' -e 'ppsspp' -e 'ubisoft' -e 'activision' -e 'com.vng.pubgmobile' -e 'pubg' -e 'com.pubg.krmobile' -e 'pubgmhd' -e 'com.tencent.tmgp.pubgmhd' -e 'GenshinImpact' -e 'com.miHoYo.GenshinImpact' -e 'rockstargames' -e 'Fortnite' -e 'FortniteMobile' -e 'com.epicgames.fortnite' -e 'epicgames' | head -n 1) ]; then
            if tail -n 1 /sdcard/ZeetaaTweaksMode.log | grep -w "Performance"
            then
            echo " "
            else
            bash $P
            echo "*" >> $LOG
            echo "* ZTS Performance Was Executed at $(date "+%H:%M:%S")" >> $LOG
            sleep 55
            fi
else
            if tail -n 1 /sdcard/ZeetaaTweaksMode.log | grep -w "Normal"
            then
            echo " "
            else
            bash $N
            echo "*" >> $LOG
            echo "* ZTS Normal Usage Was Executed at $(date "+%H:%M:%S")" >> $LOG
            fi
fi
done