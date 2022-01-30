#!/bin/sh

rm -rf *.zip

token=5073803429:AAFx8cf00fzcwtGrcDI-HfOcHviIZhNr30s
chat_id=-1001234010295


zip -r9 Zeetaa-Tweaks-Rebase-BETA.zip *

ZIP=Zeetaa-Tweaks-Rebase-BETA.zip

curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
     -F chat_id="$chat_id" \
     -F caption="Changelog: Gei"
