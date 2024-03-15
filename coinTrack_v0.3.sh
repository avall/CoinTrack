#!/bin/bash
printf '\033[8;40;140t'

FILE=holdings.txt
FILE2=collection.txt
FILE3=.settings.txt
START () {
if [[ ! -f $FILE || ! -f $FILE2 || ! -f $FILE3 ]]; then
    INSTALL
fi





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

portF=$portF

currency=USD;
j="newCoinValues.json";


echo "" > newCoinValues.json
z=0;
TABLE
}

INSTALL () {
clear
echo;echo;
echo -e "       WELCOME TO coinTrack!"
echo
echo -e "       Please enter your API Key from Cryptocompare:"
echo -n "       : "
read APIkey
touch .settings.txt
echo "APIkey=$APIkey" > .settings.txt
echo;echo;echo;
echo -e "       Please enter your first Coin-Symbol (like BTC, ETH, BNB) of the Coin you would like to Track."
echo -n "       : "
read firstCoin
echo "$firstCoin" > collection.txt
echo
echo -e "       Later you can add more Coins by pressing [a]."
echo;echo;
echo -e "       Now enter the amount of holdings, you can leave this empty if you just wish to track a Coin."
echo -n "       : "
read firstHolding
if [[ -z $firstHolding ]]; then
    echo ""$firstCoin"_Holding=0" > holdings.txt
else
    echo ""$firstCoin"_Holding=$firstHolding" > holdings.txt
fi
echo
LOGO
}


LOGO () {
clear
echo -e "                   _    _______             _     "
echo -e "                  (_)  |__   __|           | |   "
echo -e "          ___ ___  _ _ __ | |_ __ __ _  ___| | __"
echo -e "         / __/ _ \| |  _ \| |  __/ _  |/ __| |/ / "
echo -e "        | (_| (_) | | | | | | | | (_| | (__|   < "
echo -e "         \___\___/|_|_| |_|_|_|  \____|\___|_|\_\."

echo;echo;
}


# NORMAL PRICE TABLE
TABLE () {
LOGO

# Some Variables
totalValue=0;


while read zeile; do
coinsToTrack="${coinsToTrack}$zeile,"
done < collection.txt

curl -g -s -X GET "https://min-api.cryptocompare.com/data/pricemultifull?fsyms="$coinsToTrack"&tsyms=$currency&api_key={ }" | jq > newCoinValues.json

echo;
echo -e "*******  Coin  ******  Price ********* 1h% ** 24h%   .......  Holdings & Value in $currency";
echo -e "––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––";
while read coin; do

symbol=$(jq .RAW.$coin.$currency.FROMSYMBOL $j | sed s/\"//g;) # Symbol
rawPrice=$(jq .RAW.$coin.$currency.PRICE $j | sed s/\"//g;) # Current RawPrice
price=$(jq .DISPLAY.$coin.$currency.PRICE $j | sed s/\"//g;) # Current Price
change=$(jq .DISPLAY.$coin.$currency.CHANGE24HOUR $j | sed s/\"//g;) # 24h pricechange $currency
changePct=$(jq .DISPLAY.$coin.$currency.CHANGEPCT24HOUR $j | sed s/\"//g;) # 24h pricechange in %
changeHour=$(jq .DISPLAY.$coin.$currency.CHANGEHOUR $j | sed s/\"//g;) # 1h pricechange in USD
changePctHour=$(jq .DISPLAY.$coin.$currency.CHANGEPCTHOUR $j | sed s/\"//g;) # 1h pricechange in $currency


if [[ $changePct == -* ]]; then changePct=${red}$changePct${reset}; else changePct=${green}+$changePct${reset}; fi
if [[ $changePctHour == -* ]]; then changePctHour=${red}$changePctHour${reset}; else changePctHour=${green}+$changePctHour${reset}; fi
if [[ $change == -* ]]; then change=${red}$change${reset}; else change=${green}$change${reset}; fi

# Change current price color
#if [[ $change == -* ]]; then price=${red}$price${reset}; else price=${green}$price${reset}; fi


holding=$(grep $coin holdings.txt| grep -o '[0-9.]*')
value=$(awk "BEGIN {h=$holding; p=$rawPrice; vl=h*p; print vl}")


# This totalValue thing needs to be fixed
# BETRÄGE SOLLEN IN ARRAYS GESCHRIEBEN WERDEN ... txt file loswerden.
totalValue=$(awk "BEGIN {t=$totalValue; v=$value; tv=v+t; print tv}")
echo "totalValue=$totalValue" > .totalValue.txt

if [[ $portF == 0 ]]; then
    holding="******";
    value="******";
fi

echo -e "....... ${bold}${white}$symbol${reset} ... $price ... $changePctHour $changePct ....... $holding     =     ${blue}$value${reset}"; 

done < collection.txt | column -t;

source .totalValue.txt
rm .totalValue.txt
if [[ $portF == 0 ]]; then
    totalValue="****"
fi
echo;echo;
echo -e "   Total Value: ${blue}${bold}$currency $totalValue ${reset}";




echo;echo;echo;echo;
MENU
}



#### HISTORY TABLE
HISTORY () {
LOGO
while read zeile; do
coinsToTrack="${coinsToTrack}$zeile,"
done < collection.txt

curl -g -s -X GET "https://min-api.cryptocompare.com/data/pricemultifull?fsyms="$coinsToTrack"&tsyms=$currency&api_key={ }" | jq > newCoinValues.json

echo;
echo -e "*******  Coin  ******  Price ********* 1h% ** 24h% ** 3D% **  7D% **  1M%  **  3M%  **  6M%";
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




echo -e "....... ${bold}${white}$symbol${reset} ... $price ... $changePctHour $changePct $THREd $SEVENd  $ONEm  $THREm  $SIXm";

done < collection.txt | column -t;

echo;echo;echo;echo;
MENU
}


### MENU
MENU () {
echo -e "   [enter] - Refresh Price | [t] - Price History Table | [i] - Info | [q] - Quit"
echo;
echo -n "   : "
read next

case $next in  
    "q") exit ;;
    "a") ADDCOIN ;;
    "d") DELETECOIN ;;
    "i") INFO ;;
    "p") portF=0; TABLE ;;
    "P") portF=1; TABLE ;;
    "t") HISTORY ;;
    "h") HOLDINGS ;;
    *) TABLE ;;
esac

}

INFO () {
    echo -e "––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––";
    echo;echo;
    echo -e "   Key configuration INFO:"
    echo -e "   ----------------------"
    echo;
    echo -e "   [a] - Add Coin"
    echo -e "   [d] - Delete Coin"
    echo -e "   [h] - Change Holdings"
    echo
    echo -e "   [P] - Portfolio Visible"
    echo -e "   [p] - Portfolio Hidden"
    echo -e "   [q] - Quit"
    echo;echo;echo;
    MENU
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
    if [[ -z $dcoin ]]; then
        TABLE
    fi
    echo -n "   Are you sure? [y/n]: "
    read sure
    if [[ $sure == y || -z $sure ]]; then
        sed -i "$dcoin"d collection.txt
        sed -i "$dcoin"d holdings.txt
        TABLE
    else
        echo "  abort.";
        sleep 1s;
        TABLE
    fi
}
ADDCOIN () {
    echo;echo;
    echo -e "   COIN HINZUFÜGEN"
    echo -e "   ---------------"
    echo;
    echo -n "   Coinzeichen: "
    read cadd
    if [[ -z $cadd ]]; then
        TABLE
    fi
    echo "$cadd" >> collection.txt
    echo -n "   Holdings: "
    read cholding
    if [[ -z $cholding ]]; then
    echo ""$cadd"_Holding=0" >> holdings.txt
    else
    echo ""$cadd"_Holding=$cholding" >> holdings.txt
    fi
    TABLE
}

HOLDINGS () {
    echo;echo;
    echo -e "   ADD/REMOVE Holdings"
    echo -e "   -------------------"
    echo;
    nl holdings.txt | cut -d _ -f1
    echo
    echo -n "   : "
    read selectedCoinRow
    if [[ -z $selectedCoinRow ]]; then
        TABLE
    fi
    echo;echo;
    selectedCoin[0]=$(sed -n "$selectedCoinRow"p holdings.txt | cut -d _ -f1);
    selectedCoin[1]=$(sed -n "$selectedCoinRow"p holdings.txt | cut -d = -f2);
    echo -e "   You are currently holding: ${blue}${bold}${selectedCoin[1]} ${selectedCoin[0]}${reset}"
    echo -e "   ${grey}To add or subtract, simply use a plus or minus sign in front of the value (e.g.+100).${reset}"
    echo;
    echo -n "   Amount: "   
    read amount
    if [[ $amount == *"+"* ]] || [[ $amount == *"-"* ]]; then
        newAmount=$(awk "BEGIN {a=${selectedCoin[1]}; n=$amount; an=a+n; printf an}");
    else
        newAmount="$amount"
    fi
    sed -i "${selectedCoinRow}s/=.*/=$newAmount/" holdings.txt
    TABLE
}

CALLAPI () {
echo "" > newCoinValues.json

while read zeile; do
coinsToTrack="${coinsToTrack}$zeile,"
done < collection.txt

curl -g -s -X GET "https://min-api.cryptocompare.com/data/pricemultifull?fsyms="$coinsToTrack"&tsyms=USD&api_key={ }" | jq > newCoinValues.json
echo -e "CALL API WURDE AUSGEFÜHRT!!!!!"
TABLE
}

START