#!/bin/bash
if (($EUID !=0)); then
     echo Script must be run by root.
     exit
fi
#echo "Updating and Upgrading software."
apt-get update
echo "Installing requirements. "
apt-get install -y curl qrencode
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --version v24.12.18
ip=$(curl http://ifconfig.me)
uuuid=$(cat /proc/sys/kernel/random/uuid)
random_hex=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c 8)
/usr/local/bin/xray x25519 > keys.txt
awk '{print $3}' keys.txt > keys
privkey=$(head -n1 keys)
pubkey=$(tail -n1 keys)

cp config.json config.json.original
cp client_config.json client_config.json.original
sed -i "s/uuuuid/$uuuid/g" config.json
sed -i "s/pprivkey/$privkey/g" config.json
sed -i "s/ppubkey/$pubkey/g" config.json
sed -i "s/ssid/$random_hex/g" config.json
sed -i "s/ssid/$random_hex/g" client_config.json
sed -i "s/uuuuid/$uuuid/g" client_config.json
sed -i "s/ipaddr/$ip/g" client_config.json
sed -i "s/ppubkey/$pubkey/g" client_config.json

echo 'Files config.json and client_config.json is changed by your settings. Original files saved with .original postfix.'

cp config.json /usr/local/etc/xray/config.json
systemctl restart xray
link='vless://'$uuuid'@'$ip':443?security=reality&sni=images.apple.com&fp=chrome&pbk='$pubkey'&sid='$random_hex'&type=tcp&flow=xtls-rprx-vision&encryption=none#Reality'
echo "Your client link and QR-code "
echo $link
qrencode -t ANSIUTF8 $link
echo ''
echo ''
echo ''
echo $link > links.txt
echo 'Link saved in file links.txt'
echo 'Client configuration in json format you can find in client_config.json'
