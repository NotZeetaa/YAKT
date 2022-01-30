#!/bin/sh

rm -rf *.zip

token=5073803429:AAFx8cf00fzcwtGrcDI-HfOcHviIZhNr30s
chat_id=-1001234010295


zip -r9 Zeetaa-Tweaks-Rebase-BETA.zip *

ZIP=Zeetaa-Tweaks-Rebase-BETA.zip

curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
     -F chat_id="$chat_id" 

curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="Changelog:%0A- Reduce TCP performance spikes%0A- Introduce Cgroup Boost%0A- Enable ECN negotiation by default%0A"
      