#!/system/bin/sh
MODDIR=${0%/*}
nohup sh $MODDIR/script/shellscript.sh > /dev/null
