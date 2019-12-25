#!/bin/bash
#chmod 777 auto-install-cf-captcha.sh
#bash auto-install-cf-captcha.sh
cat << "EOF"
 ::::::::      :::     :::::::::  :::::::::::  ::::::::  :::    :::     :::     
:+:    :+:   :+: :+:   :+:    :+:     :+:     :+:    :+: :+:    :+:   :+: :+:   
+:+         +:+   +:+  +:+    +:+     +:+     +:+        +:+    +:+  +:+   +:+  
+#+        +#++:++#++: +#++:++#+      +#+     +#+        +#++:++#++ +#++:++#++: 
+#+        +#+     +#+ +#+            +#+     +#+        +#+    +#+ +#+     +#+ 
#+#    #+# #+#     #+# #+#            #+#     #+#    #+# #+#    #+# #+#     #+# 
 ########  ###     ### ###            ###      ########  ###    ### ###     ### 
EOF

printf "\033[1;34mCF-CAPTCHA RATELIMIT | Coded: Mr. Jaes | Telegram - @CloudFast \033[0m"

if [ -d "/root/noice/" ]; then
  printf "\033[1;31m Detected.\r\n"
  sleep .5
  printf "Remove...\r\n\033[0m"
  rm -rf /root/noice
fi

sleep .5

printf "\033[1;34m\nCloudFlare E-Mail :\n> \033[0m"
read cfemail

emailregex="^([A-Za-z]+[A-Za-z0-9]*((\.|\-|\_)?[A-Za-z]+[A-Za-z0-9]*){1,})@(([A-Za-z]+[A-Za-z0-9]*)+((\.|\-|\_)?([A-Za-z]+[A-Za-z0-9]*)+){1,})+\.([A-Za-z]{2,})+"

if ! [[ $cfemail =~ $emailregex ]] ; then

	printf "\033[1;31mInvalid email.\r\n\033[0m"
	exit

fi

printf "\033[1;34m\nCloudFlare API Key :\n> \033[0m"
read cfapikey

printf "\033[1;34m\nCloudFlare Zone ID :\n> \033[0m"
read cfzoneid

printf "\033[1;34m\nFrom the same IP address exceeds 60 seconds [Defolt 30:] \n> \033[0m"
read limit

printf "\033[1;34m\nNginx log patch [/root/nginx/site/access.log] \n> \033[0m"
read nginxlog

printf "\033[1;34m\nmode [valid values: block, challenge, js_challenge] \n> \033[0m"
read cfmode

if [[ -e /etc/debian_version ]]; then

printf "\033[1;32mUpdating your system.\r\n\033[0m"
sleep 1
apt update && apt upgrade -y
sleep 1
printf "\033c"
printf "\033[1;32mInstall modules.\r\n\033[0m"
sleep 1
apt install cron curl sudo htop -y
sleep 1
wget http://stedolan.github.io/jq/download/linux64/jq
sleep 1
chmod +x ./jq
sudo cp jq /usr/bin
sleep 1
rm jq
sleep 3
printf "\033c"
printf "\033[1;32mDone! [captcha].\r\n\033[0m"
printf "\033[1;32mDone! [unban].\r\n\033[0m"
sleep 1
mkdir /root/noice
cd /root/noice
	
cat > captcha.sh << EOF
#!/bin/bash
ip=\`cat $nginxlog | awk '{print \$1}' | sort | uniq -c | sort -n| sed 's/^[ \t]*//' | awk '{if (\$1 > $limit ) print\$2}'\`
IPS=\`echo \$ip\`
for number in \$IPS; do
curl -X POST "https://api.cloudflare.com/client/v4/zones/$cfzoneid/firewall/access_rules/rules" \\
-H "X-Auth-Email: $cfemail" \\
-H "X-Auth-Key: $cfapikey" \\
-H "Content-Type: application/json" \\
--data '{"mode":"$cfmode","configuration":{"target":"ip","value":"'\$number'"},"notes":"add by noice"}'
done

echo > $nginxlog
EOF

cat > unban.sh << EOF
#!/bin/bash
#Shit code but it works ;)
RESULT=\`
     curl -X GET "https://api.cloudflare.com/client/v4/zones/$cfzoneid/firewall/access_rules/rules?page=1&per_page=25&mode=$cfmode&notes=add by noice&match=all&order=mode&direction=asc" \\
     -H "X-Auth-Email: $cfemail" \\
     -H "X-Auth-Key: $cfapikey" \\
     -H "Content-Type: application/json"\\
echo \$RESULT > /root/noice/json.json

#countfile=\`cat /root/cf-captcha/json.json | wc -l\`
for (( i=0; i <= 20; i++ ))
do
var=\`cat /root/noice/json.json | jq '.result['\$i'].id'\`
if ! [[ "\$var" == "null" ]]; then
echo \$var  | tr --delete '"' >> /root/noice/decode.json
fi
done

id=\`cat /root/noice/decode.json\`
ln=\`echo \$id\`
for number in \$ln; do
curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$cfzoneid/firewall/access_rules/rules/'"\$number"'" \\
     -H "X-Auth-Email: $cfemail" \\
     -H "X-Auth-Key:  $cfapikey" \\
     -H "Content-Type: application/json" \\
     --data '{"cascade":"none"}'
done
rm decode.json
rm json.json
EOF

chmod 500 /root/noice/
chmod 500 /root/noice/captcha.sh
chmod 500 /root/noice/unban.sh
crontab -l > cron1
echo "* * * * * cd /root/noice/ ; sleep 60 ; bash captcha.sh" >> cron1
crontab cron1
rm cron1
crontab -l > cron2
echo "0 */2 * * * cd /root/noice/ ; bash unban.sh" >> cron2
crontab cron2
rm cron2
service cron restart

else
	printf "Installer Debian and Ubuntu."
	exit 1
fi

printf "\033[1;32mInstall Done!\033[0m"
printf "\033[1;32m Donate, BTC - 12AGRKzHgCLFdG6bRxYxX1UBfJCYC3372C \033[0m"
printf "\r\n\r\n"
exit
