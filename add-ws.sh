#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################



clear
if [[ "$IP" = "" ]]; then
domain=$(cat /etc/xray/domain)
else
domain=$IP
sldomain=`cat /etc/xray/dns`
slkey=`cat /etc/slowdns/server.pub`
fi

until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[40;1;37m      Add Xray/Vmess Account      \E[0m"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -p "Username         : " user
read -p "Quota (GB)       : " quota
read -p "Max Ip login     : " iplimit
read -p "Masaaktif        : " masaaktif
		CLIENT_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
clear
            echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
            echo -e "\\E[40;1;37m      Add Xray/Vmess Account      \E[0m"
            echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
			echo ""
			echo "A client with the specified name was already created, please choose another name."
			echo ""
			echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
			read -n 1 -s -r -p "Press any key to back on menu"
v2ray-menu
		fi
	done
if [[ $quota -gt 0 ]]; then
echo -e "$[$quota * 1024 * 1024 * 1024]" > /etc/anggun/limit/vmess/quota/$user
else
echo > /dev/null
fi
if [[ $iplimit -gt 0 ]]; then
echo -e "$iplimit" > /etc/anggun/limit/vmess/ip/$user
else
echo > /dev/null
fi
uuid=$(cat /proc/sys/kernel/random/uuid)
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vmess$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vmessgrpc$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
acs=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "${domain}",
      "tls": "tls"
}
EOF`
ask=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "80",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "${domain}",
      "tls": "none"
}
EOF`
grpc=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "grpc",
      "path": "vmess-grpc",
      "type": "none",
      "host": "${domain}",
      "tls": "tls"
}
EOF`
vmess_base641=$( base64 -w 0 <<< $vmess_json1)
vmess_base642=$( base64 -w 0 <<< $vmess_json2)
vmess_base643=$( base64 -w 0 <<< $vmess_json3)
vmesslink1="vmess://$(echo $acs | base64 -w 0)"
vmesslink2="vmess://$(echo $ask | base64 -w 0)"
vmesslink3="vmess://$(echo $grpc | base64 -w 0)"
systemctl restart xray > /dev/null 2>&1
service cron restart > /dev/null 2>&1
clear


cat >/var/www/html/vmess-$user.txt <<-END

◇━━━━━━━━━━━━━━━━━◇
   Format For Clash
◇━━━━━━━━━━━━━━━━━◇

# Format Vmess WS TLS

- name: Vmess-$user-WS TLS
  type: vmess
  server: ${domain}
  port: 443
  uuid: ${uuid}
  alterId: 0
  cipher: auto
  udp: true
  tls: true
  skip-cert-verify: true
  servername: ${domain}
  network: ws
  ws-opts:
    path: /vmess
    headers:
      Host: ${domain}

# Format Vmess WS Non TLS

- name: Vmess-$user-WS Non TLS
  type: vmess
  server: ${domain}
  port: 80
  uuid: ${uuid}
  alterId: 0
  cipher: auto
  udp: true
  tls: false
  skip-cert-verify: false
  servername: ${domain}
  network: ws
  ws-opts:
    path: /vmess
    headers:
      Host: ${domain}

# Format Vmess gRPC

- name: Vmess-$user-gRPC (SNI)
  server: ${domain}
  port: 443
  type: vmess
  uuid: ${uuid}
  alterId: 0
  cipher: auto
  network: grpc
  tls: true
  servername: ${domain}
  skip-cert-verify: true
  grpc-opts:
    grpc-service-name: vmess-grpc

◇━━━━━━━━━━━━━━━━━◇
 Link Akun Vmess                   
◇━━━━━━━━━━━━━━━━━◇
Link TLS         : 
${vmesslink1}
◇━━━━━━━━━━━━━━━━━◇
Link none TLS    : 
${vmesslink2}
◇━━━━━━━━━━━━━━━━━◇
Link GRPC        : 
${vmesslink3}
◇━━━━━━━━━━━━━━━━━◇

END

echo -e "══════════════════════════"                 
echo -e "    <=  VMESS ACCOUNT =>"       
echo -e "══════════════════════════"                 
echo -e ""                
echo -e "Username     : $user"
echo -e "CITY         : $(cat /root/.mycity)"
echo -e "ISP          : $(cat /root/.myisp)"
echo -e "Host/IP      : $(cat /etc/xray/domain)"
echo -e "NSDOMAIN     : $(cat /etc/xray/dns)"
echo -e "PUBKEY       : $(cat /etc/slowdns/server.pub)"
echo -e "Slowdns      : 53, 5300"
echo -e "Port tls/ssl : 443"
echo -e "Port non tls : 80, 8080, 8880"
echo -e "Key          : $uuid"
echo -e "Network      : ws, grpc"
echo -e "Path         : /Multi-Path"
echo -e "dynamic      : https://bugmu.com/path"                               
echo -e "serviceName  : vmess-grpc"               
echo -e ""  
echo -e "══════════════════════════"                 
echo -e "Link Tls  => ${vmesslink1}"
echo -e "══════════════════════════"                 
echo -e "Link None => ${vmesslink2}"
echo -e "══════════════════════════"                 
echo -e "Link Grpc => ${vmesslink3}"
echo -e "══════════════════════════"   
echo -e "Format OpenClash : http://${domain}:81/vmess-$user.txt"              
echo -e "   Expired => $exp"
echo -e "══════════════════════════"                 
read -n 1 -s -r -p "Press any key to back on menu"
menu
