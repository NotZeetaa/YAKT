#!/usr/bin/env bash
MODULE=Zeetaa-Tweaks-Rebase
VERSION=BETA
TOKEN=5073803429:AAFx8cf00fzcwtGrcDI-HfOcHviIZhNr30s
CHATID=-1001234010295
function post_file() {
curl -F document=@$1 "https://api.telegram.org/bot${TOKEN}/sendDocument" \
     -F chat_id="${CHATID}"  \
     -F "disable_web_page_preview=true" \
     -F "parse_mode=html" \
     -F caption="Changelog: Gei"
}
rm -rf Zeetaa-Tweaks-Rebase-*
zip -r9 "${MODULE}-${VERSION}.zip" . -x *build* -x *.bak* -x *.git*
post_file "${MODULE}-${VERSION}.zip"
