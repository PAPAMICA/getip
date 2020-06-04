#!/bin/bash

# Getip Plugin for XFCE by Mickael Asseline (PAPAMICA)


network=$(nmcli con show --active)
if [ "$network" = "" ]; then
  echo "<img>/home/papamica/.img/ping-error.png</img>"
  tf="CHECK NETWORK"
  color="Red"
  echo "<tool><span weight='Bold' fgcolor='$color'>"$tf"</span></tool>"
  exit
fi 

interface=$(ip route get 8.8.8.8 | awk -F"dev " 'NR==1{split($2,a," ");print a[1]}')

if [ $interface != "unreachable" ]; then
    ipadress=$(ifconfig "$interface" | awk '/inet /{ print $2;}')
    ipadressbak=$(cat ~/.getip-temp)
    if [[ "$ipadress" != "$ipadressbak" ]]; then
    rm ~/.getip-temp
    rm ~/.getip-temp2
    gateway=$(nmcli dev show $interface |grep IP4.GATEWAY | awk '{print $2 }')
    mask=$(ifconfig "$interface" | awk '/netmask/{ print $4;}')
    dns=$(nmcli dev show $interface | grep DNS | awk '{if(NR==1) print $2}')
    dns2=$(nmcli dev show $interface |grep DNS | awk '{if(NR==2) print $2}')
    domain=$(nmcli dev show $interface | grep DOMAIN | sed 's/\s\s*/\t/g' | cut -f 2)
    mac=$(cat /sys/class/net/$interface/address)
    nom=$(nmcli dev show $interface |grep GENERAL.CONNECTION | awk '{print $2 " "  $3 " " $4 " " $5 " " $6}')   
    mtu=$(cat /sys/class/net/$interface/mtu)
    rxerror=$(cat /sys/class/net/$interface/statistics/rx_errors)
    txerror=$(cat /sys/class/net/$interface/statistics/tx_errors)
    rxdropped=$(cat /sys/class/net/$interface/statistics/rx_dropped)
    txdropped=$(cat /sys/class/net/$interface/statistics/tx_dropped)
    wan=$(curl -s ifconfig.io)
    ipadressbak=$ipadress
    echo $ipadress > ~/.getip-temp

    echo "LAN IP Address :      <span weight='Bold'>"$ipadress"</span>
  Gateway :                    <span weight='Bold'>"$gateway"</span>
  Mask :                           <span weight='Bold'>"$mask"</span>

  DNS Server :              <span weight='Bold'>"$dns"</span>

  Interface :                   <span weight='Bold'>"$interface"</span>
  Name :                          <span weight='Bold'>"$nom"</span>
  MAC Address :           <span weight='Bold'>"$mac"</span>
  MTU :                            <span weight='Bold'>"$mtu"</span>
  Domain :                      <span weight='Bold'>"$domain"</span>

  WAN IP Address :     <span weight='Bold'>"$wan"</span>" > ~/.getip-temp2
    fi

  ipinfo=$(cat ~/.getip-temp2)

# Vérification de la connexion à Internet via IP
  t="0"  
  t="$(timeout 0.8s ping -c 1 -W 1 8.8.8.8 | tail -1| awk -F '/' '{print $5}')"
  if [ -z "$t" ]; then
  echo "<img>/home/papamica/.img/ping-error.png</img>"
  #echo "<txt>  ERROR</txt>"
  color="Red"
  tf="ERROR"
  fi

  if [ -n "$t" ]; then
  t=${t%.*}
  ((t++))
    if [ "$t" -eq 1 ]; then
    echo "<img>/home/papamica/.img/ping-ok.png</img>"
    #echo "<txt>  <"$t" ms</txt>"
    tf="<$t ms"
    color="Green"
    elif [ "$t" -gt 1 ] && [ "$t" -le 100 ]; then
    echo "<img>/home/papamica/.img/ping-ok.png</img>"
    #echo "<txt>  "$t" ms</txt>"
    color="Green"
    tf="$t ms"
    elif [ "$t" -gt 100 ] && [ "$t" -le 500 ]; then
    echo "<img>/home/papamica/.img/ping-bad.png</img>"
    #echo "<txt>  "$t" ms</txt>"
    color="Yellow"
    tf="$t ms"
    else
    echo "<img>/home/papamica/.img/ping-error.png</img>"
    #echo "<txt>  "$t" ms</txt>"
    color="Red"
    tf="$t ms"
    fi
  fi
else
  echo "<img>/home/papamica/.img/ping-error.png</img>"
  tf="CHECK IP"
  color="Red"
  echo "<tool><span weight='Bold' fgcolor='$color'>"$tf"</span></tool>"
  exit
fi
echo "<tool>
  PING :                           <span weight='Bold' fgcolor='$color'>"$tf"</span>

  $ipinfo </tool>"
