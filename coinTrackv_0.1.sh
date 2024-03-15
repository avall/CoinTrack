#!/bin/bash
printf '\033[8;40;140t'

TABLE () {
clear

echo -e "                   _    _______             _     "
echo -e "                  (_)  |__   __|           | |   "
echo -e "          ___ ___  _ _ __ | |_ __ __ _  ___| | __"
echo -e "         / __/ _ \| |  _ \| |  __/ _  |/ __| |/ / "
echo -e "        | (_| (_) | | | | | | | | (_| | (__|   < "
echo -e "         \___\___/|_|_| |_|_|_|  \____|\___|_|\_\."

echo;echo;

source holdings.txt;

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
totalValue=0;

echo "" > newCoinValues.json
z=0;
while read zeile; do
coinsToTrack="${coinsToTrack}$zeile,"
done < collection.txt
curl -g -s -X GET "https://min-api.cryptocompare.com/data/pricemultifull?fsyms="$coinsToTrack"&tsyms=$currency&api_key={ }" | jq > newCoinValues.json

echo;
echo -e "*******  Coin  ******  Price ********* 1h% ** 24h% ** 3D% **  7D% **  1M%  **  3M%  **  6M%    .......  Holdings & Value in $currency";
echo -e "––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––";
while read coin; do
symbol=$(jq .RAW.$coin.$currency.FROMSYMBOL $j | sed s/\"//g;) # Symbol
rawPrice=$(jq .RAW.$coin.$currency.PRICE $j | sed s/\"//g;) # Current RawPrice
price=$(jq .DISPLAY.$coin.$currency.PRICE $j | sed s/\"//g;) # Current Price
change=$(jq .DISPLAY.$coin.$currency.CHANGE24HOUR $j | sed s/\"//g;) # 24h pricechange $currency
changePct=$(jq .DISPLAY.$coin.$currency.CHANGEPCT24HOUR $j | sed s/\"//g;) # 24h pricechange in %
changeHour=$(jq .DISPLAY.$coin.$currency.CHANGEHOUR $j | sed s/\"//g;) # 1h pricechange in USD
changePctHour=$(jq .DISPLAY.$coin.$currency.CHANGEPCTHOUR $j | sed s/\"//g;) # 1h pricechange in $currency


history=$(curl -g -s -X GET "https://min-api.cryptocompare.com/data/v2/histoday?fsym="$coin"&tsym=$currency&limit=182&api_key={ ");
# History Price-Changes. To round numbers after . use "LC_ALL=C /usr/bin/printf" because of german locale Numberformat using , instad of . ( 6,666).
SIXm=$(printf $history | jq '.Data.Data.[0].close');
SIXm=$(awk "BEGIN {a=$SIXm; e=$rawPrice; ep=(e-a)/a*100; printf ep}");
SIXm=$(LC_ALL=C /usr/bin/printf '%.*f\n' 2 $SIXm);

THREm=$(printf $history | jq '.Data.Data.[90].close');
THREm=$(awk "BEGIN {a=$THREm; e=$rawPrice; ep=(e-a)/a*100; printf ep}");
THREm=$(LC_ALL=C /usr/bin/printf '%.*f\n' 2 $THREm);

ONEm=$(printf $history | jq '.Data.Data.[152].close');
ONEm=$(awk "BEGIN {a=$ONEm; e=$rawPrice; ep=(e-a)/a*100; printf ep}");
ONEm=$(LC_ALL=C /usr/bin/printf '%.*f\n' 2 $ONEm);

SEVENd=$(printf $history | jq '.Data.Data.[175].close');
SEVENd=$(awk "BEGIN {a=$SEVENd; e=$rawPrice; ep=(e-a)/a*100; printf ep}");
SEVENd=$(LC_ALL=C /usr/bin/printf '%.*f\n' 2 $SEVENd);

THREd=$(printf $history | jq '.Data.Data.[179].close');
THREd=$(awk "BEGIN {a=$THREd; e=$rawPrice; ep=(e-a)/a*100; printf ep}");
THREd=$(LC_ALL=C /usr/bin/printf '%.*f\n' 2 $THREd);

if [[ $changePct == -* ]]; then changePct=${red}$changePct${reset}; else changePct=${green}+$changePct${reset}; fi
if [[ $changePctHour == -* ]]; then changePctHour=${red}$changePctHour${reset}; else changePctHour=${green}+$changePctHour${reset}; fi
if [[ $change == -* ]]; then change=${red}$change${reset}; else change=${green}$change${reset}; fi

if [[ $SIXm == -* ]]; then SIXm=${red}$SIXm${reset}; else SIXm=${green}+$SIXm${reset}; fi
if [[ $THREm == -* ]]; then THREm=${red}$THREm${reset}; else THREm=${green}+$THREm${reset}; fi
if [[ $ONEm == -* ]]; then ONEm=${red}$ONEm${reset}; else ONEm=${green}+$ONEm${reset}; fi
if [[ $SEVENd == -* ]]; then SEVENd=${red}$SEVENd${reset}; else SEVENd=${green}+$SEVENd${reset}; fi
if [[ $THREd == -* ]]; then THREd=${red}$THREd${reset}; else THREd=${green}+$THREd${reset}; fi

#if [[ $change == -* ]]; then price=${red}$price${reset}; else price=${green}$price${reset}; fi


holding=$(grep $coin holdings.txt| grep -o '[0-9.]*')
value=$(awk "BEGIN {h=$holding; p=$rawPrice; vl=h*p; print vl}")

# This totalValue thing needs to be fixed
totalValue=$(awk "BEGIN {t=$totalValue; v=$value; tv=v+t; print tv}")
echo "totalValue=$totalValue" > .totalValue.txt

echo -e "$space ${bold}${white}$symbol${reset} ... $price ... $changePctHour $changePct $THREd $SEVENd  $ONEm  $THREm  $SIXm   ....... $holding     =     ${blue}$value${reset}"; 

done < collection.txt | column -t;

source .totalValue.txt
rm .totalValue.txt
echo;echo;
echo -e "   Total Value: ${blue}${bold}$currency $totalValue ${reset}";




echo;echo;echo;echo;
echo -e "   [enter] - Refresh Price | [a] - Add Coin | [d] - Delete Coin | [x] - Exit"
echo;
echo -n "   : "
read next

case $next in  
    "x") exit ;;
    "a") ADDCOIN ;;
    "d") DELETECOIN ;;
    "n") NAV ;;
    *) TABLE ;;
esac

}

ADDCOIN () {
    echo;echo;
    echo -e "   COIN HINZUFÜGEN"
    echo -e "   ---------------"
    echo;
    echo -n "   Coinzeichen: "
    read cadd
    echo "$cadd" >> collection.txt
    echo -n "   Holdings: "
    read cholding
    echo ""$cadd"_Holding=$cholding" >> holdings.txt
    

    TABLE
}

SHOWCOIN () {
    echo;echo;
    echo -e "   HINTERLEGTE COINS"
    echo -e "   -----------------"
    echo
    nl collection.txt
    echo;echo;

    echo -n "   [enter]"
    read nnn

    TABLE
}

DELETECOIN () {
    echo;echo;
    echo -e "   COIN LÖSCHEN"
    echo -e "   ------------"
    echo;
    nl collection.txt
    echo;echo

    echo -n "   Nr.: "
    read dcoin
    echo -n "   Are you sure? [y/n]: "
    read sure
    if [[ $sure == y || -z $sure ]]; then
        sed -i /$dcoin\*/d collection.txt holdings.txt
        TABLE
    else
        echo "  abort.";
        sleep 1s;
        TABLE
    fi
}

ADDHOLDING () {
    echo;echo;
    echo -e "   ADD HOLDINGING"
    echo -e "   --------------"
    echo;
    nl collection.txt
    echo;echo
    echo -n
}

CALLAPI () {
echo "" > newCoinValues.json

while read zeile; do
coinsToTrack="${coinsToTrack}$zeile,"
done < collection.txt

curl -g -s -X GET "https://min-api.cryptocompare.com/data/pricemultifull?fsyms="$coinsToTrack"&tsyms=USD&api_key={ }" | jq > newCoinValues.json

TABLE
}

TABLE