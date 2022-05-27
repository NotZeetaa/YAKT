SKIPUNZIP=1
RM_RF() {
rm -rf /sdcard/yakt.log 2>/dev/null
rm -rf /sdcard/yakt_mode.log 2>/dev/null
rm -rf $MODPATH/LICENSE 2>/dev/null
rm -rf $MODPATH/README.md 2>/dev/null
}
SET_PERMISSION() {
ui_print "- Setting Permissions"
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive $MODPATH/scripts 0 0 0755 0700
}
MOD_EXTRACT() {
ui_print "- Extracting Module Files"
unzip -o "$ZIPFILE" 'scripts/*' -d $MODPATH >&2
unzip -o "$ZIPFILE" service.sh -d $MODPATH >&2
unzip -o "$ZIPFILE" module.prop -d $MODPATH >&2
}
MOD_PRINT() {
ui_print "- YAKT"
ui_print "- Installing"
}
set -x
RM_RF
MOD_PRINT
MOD_EXTRACT
SET_PERMISSION
