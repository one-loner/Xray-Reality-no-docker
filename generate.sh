#!/bin/bash

echo "Warning! This script only generates configurations and links."
echo ""
read -p "Press Enter to continue or CTRL+C to exit script"
uuuid=$(cat /proc/sys/kernel/random/uuid)
random_hex=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c 8)
/usr/local/bin/xray x25519 > keys.txt
awk '{print $3}' keys.txt > keys
privkey=$(head -n1 keys)
pubkey=$(tail -n1 keys)

cp config.json config_generate.json
cp client_config.json client_config_generate.json
sed -i "s/uuuuid/$uuuid/g" config_generate.json
sed -i "s/pprivkey/$privkey/g" config_generate.json
sed -i "s/ppubkey/$pubkey/g" config_generate.json
sed -i "s/ssid/$random_hex/g" config_generate.json
sed -i "s/ssid/$random_hex/g" client_config_generate.json
sed -i "s/uuuuid/$uuuid/g" client_config_generate.json
sed -i "s/ipaddr/$ip/g" client_config_generate.json
sed -i "s/ppubkey/$pubkey/g" client_config_generate.json

link='vless://'$uuuid'@'$ip':443?security=reality&sni=images.apple.com&fp=chrome&pbk='$pubkey'&sid='$random_hex'&type=tcp&flow=xtls-rprx-vision&encryption=none#Reality'
echo "Your client link and QR-code "
echo $link
qrencode -t ANSIUTF8 $link
echo ''
echo ''
echo ''
echo $link > link_generate.txt
echo 'Link saved in file link_generate.txt'

