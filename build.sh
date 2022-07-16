#!/usr/bin/env bash
TM=$(date +"%F-%S")
clog=`cat changelog.txt`
function push() {
curl -F document=@$1 "https://api.telegram.org/bot${token}/sendDocument" \
     -F chat_id="${chat_id}"  \
     -F "disable_web_page_preview=true" \
     -F "parse_mode=html" \
     -F caption="${clog}"
}
echo ""
rm -rf *.zip
zip -r9 "YAKT-STAGING-${TM}.zip" . -x *build* -x *changelog* -x *.bak* -x *.git*
push "YAKT-STAGING-${TM}.zip"
