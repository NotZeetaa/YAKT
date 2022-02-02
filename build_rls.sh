#!/usr/bin/env bash
token=5073803429:AAFx8cf00fzcwtGrcDI-HfOcHviIZhNr30s
chatid=-1001571220955
clog=`cat changelog.txt`
function post_file() {
curl -F document=@$1 "https://api.telegram.org/bot${token}/sendDocument" \
     -F chat_id="${chatid}"  \
     -F "disable_web_page_preview=true" \
     -F "parse_mode=html" \
     -F caption="${clog}"
}
echo ""
echo -n "Give me version name : "
read -r Version
rm -rf Zeetaa-Tweaks-Rebase-*
zip -r9 "Zeetaa-Tweaks-Rebase-${version}.zip" . -x *build* -x *changelog* -x *.bak* -x *.git*
post_file "Zeetaa-Tweaks-Rebase-${version}.zip"
