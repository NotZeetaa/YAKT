set -x
SKIPUNZIP=1
MODLOG=/sdcard/ZeetaaTweaks.log
RM_RF() {
rm -rf $MODLOG 2>/dev/null
rm -rf $MODPATH/LICENSE 2>/dev/null
rm -rf $MODPATH/README.md 2>/dev/null
}
SET_PERMISSION() {
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive $MODPATH/script 0 0 0755 0700
}
MOD_EXTRACT() {
ui_print "- Extracting module files"
unzip -o "$ZIPFILE" 'script/*' -d $MODPATH >&2
unzip -o "$ZIPFILE" service.sh -d $MODPATH >&2
unzip -o "$ZIPFILE" module.prop -d $MODPATH >&2
}
MOD_PRINT() {
ui_print ""
ui_print "*************************************"
ui_print " Zeetaa Tweaks Module Rebase V1.8. "
ui_print " Thx to lybdroid for his module template.      "
ui_print "*************************************"
ui_print ""
}
RM_RF
MOD_PRINT
MOD_EXTRACT
SET_PERMISSION
