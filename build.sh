#!/usr/bin/env bash
clog=$(cat changelog.txt)
function push() {
# shellcheck disable=SC2154
curl -F document="@$1" "https://api.telegram.org/bot${token}/sendDocument" \
     -F chat_id="${chat_id}"  \
     -F "disable_web_page_preview=true" \
     -F "parse_mode=html" \
     -F caption="${clog}"
}
echo ""
rm -rf ./*.zip
zip -r9 "YAKT-v14.zip" . -x "*build*" "*changelog*" "*.bak*" "*.git*"
push "YAKT-v14.zip"
