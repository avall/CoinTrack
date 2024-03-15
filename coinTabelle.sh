#!/bin/bash
clear

echo -e "                   _    _______             _     "
echo -e "                  (_)  |__   __|           | |   "
echo -e "          ___ ___  _ _ __ | |_ __ __ _  ___| | __"
echo -e "         / __/ _ \| |  _ \| |  __/ _  |/ __| |/ / "
echo -e "        | (_| (_) | | | | | | | | (_| | (__|   < "
echo -e "         \___\___/|_|_| |_|_|_|  \____|\___|_|\_\."

echo;echo;

source holdings.txt;
source getNewValues.sh

# Farben Palette
red="\e[0;31m" # ${red}
green="\e[0;32m" # ${green}
white="\e[1;37m" # ${white}
blue="\e[0;94m" # ${blue}
grey="\e[0;31m" # ${grey}
violet="\e[0;36" # ${violet}
bold="\e[1m" # ${bold}
reset="\e[0m" # ${reset}

currency=USD;
j="newCoinValues.json";
space=".......";
echo;echo;
echo -e "         Coin      Price      1h%   24h%  /  Holdings   |  Value in $currency";
echo -e "--------------------------------------------------------------------------";
while read coin; do
symbol=$(jq .RAW.$coin.$currency.FROMSYMBOL $j | sed s/\"//g;) # Symbol
rawPrice=$(jq .RAW.$coin.$currency.PRICE $j | sed s/\"//g;) # Current RawPrice
price=$(jq .DISPLAY.$coin.$currency.PRICE $j | sed s/\"//g;) # Current Price
change=$(jq .DISPLAY.$coin.$currency.CHANGE24HOUR $j | sed s/\"//g;) # 24h pricechange $currency
changePct=$(jq .DISPLAY.$coin.$currency.CHANGEPCT24HOUR $j | sed s/\"//g;) # 24h pricechange in %
changeHour=$(jq .DISPLAY.$coin.$currency.CHANGEHOUR $j | sed s/\"//g;) # 1h pricechange in USD
changePctHour=$(jq .DISPLAY.$coin.$currency.CHANGEPCTHOUR $j | sed s/\"//g;) # 1h pricechange in $currency

if [[ $changePct == -* ]]; then changePct=${red}$changePct${reset}; else changePct=${green}+$changePct${reset}; fi
if [[ $changePctHour == -* ]]; then changePctHour=${red}$changePctHour${reset}; else changePctHour=${green}$changePctHour${reset}; fi
if [[ $change == -* ]]; then change=${red}$change${reset}; else change=${green}$change${reset}; fi


holding=$(grep $coin holdings.txt| grep -o '[0-9.]*')
value=$(awk "BEGIN {h=$holding; p=$rawPrice; vl=h*p; print vl}")



echo -e "$space ${bold}${white}$symbol${reset}   $price            $changePctHour $changePct    /    $holding     =     $value"; 
done < collection.txt | column -t
echo;echo;echo;echo;
echo -e "   [r] - Refresh Price | [m] - Menu | [x] - Exit"
echo;
echo -n "   : "
read next

case $next in 
    "r") CALLAPI ;;
    "m") source collection.sh ;;
    *) exit ;;
esac
