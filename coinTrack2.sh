#!/bin/bash
printf '\033[8;40;140t'

# Farben Palette
red="\e[0;31m" # ${red}
green="\e[0;32m" # ${green}
white="\e[1;37m" # ${white}
blue="\e[0;94m" # ${blue}
grey="\e[0;31m" # ${grey}
violet="\e[0;36" # ${violet}
bold="\e[1m" # ${bold}
reset="\e[0m" # ${reset}


jsonFile=db.json
START () {
    if [[ ! -f $jsonFile ]]; then
        jsonFile=$(jq --null-input '{"DATA": {"apiKey": null, "Currency": "USD", "Portfolio": "1", "Coins": {"BTC": {"Holding": null, "FIATholding": null, "currentPrice": null, "rawCurrentPrice": null}, "ETH": {"Holding": null, "FIATholding": null, "currentPrice": null, "rawCurrentPrice": null}, "BNB": {"Holding": null, "FIATholding": null, "currentPrice": null, "rawCurrentPrice": null}, "SOL": {"Holding": null, "FIATholding": null, "currentPrice": null, "rawCurrentPrice": null}, "DOGE": {"Holding": null, "FIATholding": null, "currentPrice": null, "rawCurrentPrice": null},}}}');
        echo "$jsonFile" > db.json
        INSTALL
    fi

TABLE
}

INSTALL () {
clear
echo;echo;
echo -e "       WELCOME TO"
echo -e "                   _    _______             _     "
echo -e "                  (_)  |__   __|           | |   "
echo -e "          ___ ___  _ _ __ | |_ __ __ _  ___| | __"
echo -e "         / __/ _ \| |  _ \| |  __/ _  |/ __| |/ / "
echo -e "        | (_| (_) | | | | | | | | (_| | (__|   < "
echo -e "         \___\___/|_|_| |_|_|_|  \____|\___|_|\_\."
echo;
echo;
echo -e "       You need to get a (free) API Key from https://min-api.cryptocompare.com/ in order for coinTrack to work."
echo -e "       Please enter your API Key from Cryptocompare:"
echo -n "       : "
read APIkey

jsonFile=$(cat db.json | jq)
jsonFile=$(echo "$jsonFile" | jq --arg apiKey "$APIkey" '.DATA += {"apiKey": $apiKey}')
echo "$jsonFile" | jq > db.json

echo "APIkey=$APIkey" > .apiKey.txt
echo;
APITEST
echo;echo;
echo -e "       You can add your Coins by typing a and enter. Delete Coins with d."
echo -e "       Add your holdings by typing h and enter. All info about Key you find by typing i."
read enter

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


############################# PRICE TABLE
TABLE () {
LOGO

# Some Variables
jsonFile=$(cat db.json | jq)
portF=$(echo "$jsonFile" | jq .DATA.Portfolio | sed s/\"//g;);
currency=$(echo "$jsonFile" | jq .DATA.Currency | sed s/\"//g;);

#Count amount of CoinstoTrack
n=$(echo "$jsonFile" | jq '.DATA.Coins | length')


z=0;
totalValue=0;


# Generate coinsToTrack
coinsToTrack=$(echo "$jsonFile" | jq '.DATA.Coins | keys.[]' | sed 's/\"//g;s/$/,/' | tr -d '\n')


newValues=$(curl -g -s -X GET "https://min-api.cryptocompare.com/data/pricemultifull?fsyms="$coinsToTrack"&tsyms=$currency&api_key={$APIkey}" | jq)


echo;
echo -e "*******  Coin  ******  Price ********* 1h% ** 24h%  .......  Holdings & Value in $currency";
echo -e "––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––";
for (( i=0; i<$n; i++ ));  do

# Get the Coinsymbols from db.json
coin=$(echo "$jsonFile" | jq ".DATA.Coins | keys.[$i]" | sed 's/\"//g') # Symbol


rawPrice=$(echo "$newValues" | jq .RAW.$coin.$currency.PRICE | sed s/\"//g;) # Current RawPrice
price=$(echo "$newValues" | jq .DISPLAY.$coin.$currency.PRICE | sed s/\"//g;) # Current Price
change=$(echo "$newValues" | jq .DISPLAY.$coin.$currency.CHANGE24HOUR | sed s/\"//g;) # 24h pricechange $currency
changePct=$(echo "$newValues" | jq .DISPLAY.$coin.$currency.CHANGEPCT24HOUR | sed s/\"//g;) # 24h pricechange in %
changeHour=$(echo "$newValues" | jq .DISPLAY.$coin.$currency.CHANGEHOUR | sed s/\"//g;) # 1h pricechange in USD
changePctHour=$(echo "$newValues" | jq .DISPLAY.$coin.$currency.CHANGEPCTHOUR | sed s/\"//g;) # 1h pricechange in $currency


if [[ $changePct == -* ]]; then changePct=${red}$changePct${reset}; else changePct=${green}+$changePct${reset}; fi
if [[ $changePctHour == -* ]]; then changePctHour=${red}$changePctHour${reset}; else changePctHour=${green}+$changePctHour${reset}; fi
if [[ $change == -* ]]; then change=${red}$change${reset}; else change=${green}$change${reset}; fi

# Change current price color
#if [[ $change == -* ]]; then price=${red}$price${reset}; else price=${green}$price${reset}; fi


holding=$(echo "$jsonFile" | jq ".DATA.Coins.$coin.Holding" | sed s/\"//g;) # get Holdings
value=$(awk "BEGIN {h=$holding; p=$rawPrice; vl=h*p; print vl}")


#jq --null-input --arg Coin "$symbol" --arg Preis "$price" --arg Wert "$value" --arg WertRaw "$rawPrice" --arg Holding "$holding" '{$Coin: {"Preis": $Preis, "Wert": $Wert, "WertRaw": $WertRaw, "Holding": $Holding}}' > ./data/$symbol.json

if [[ ! -f ./data/coinValues.json ]]; then
    jsonFile=$(jq --null-input '{coins: {}}')
    echo "$jsonFile" > coinValues.json
fi
jsonFile=$(echo "$jsonFile" | jq --arg Coin "$symbol" --arg Preis "$price" --arg rawPreis "$rawPrice" --arg holding "$holding" --arg fiatHolding "$value" '.coins += {$Coin: {"Preis": $Preis, "rawPreis": $rawPreis, "holding": $holding, "fiatHolding": $fiatHolding }}')
echo $jsonFile | jq > ./data/coinValues.json

#jq --null-input --arg Coin "$symbol" --arg Preis "$price" --arg Wert "$value" '{$Coin: {"Preis": $Preis, "Wert": $Wert}}' >> ./data/coinWerte.json


# This totalValue thing needs to be fixed
# BETRÄGE SOLLEN IN ARRAYS GESCHRIEBEN WERDEN ... txt file loswerden.
totalValue=$(awk "BEGIN {t=$totalValue; v=$value; tv=v+t; print tv}")
echo "totalValue=$totalValue" > .totalValue.txt

if [[ $portF == 0 ]]; then
    holding="******";
    value="******";
fi

echo -e "....... ${bold}${white}$coin${reset} ... $price ... $changePctHour $changePct  ....... $holding     =     ${blue}$value${reset}"; 

done | column -t;

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

curl -g -s -X GET "https://min-api.cryptocompare.com/data/pricemultifull?fsyms="$coinsToTrack"&tsyms=$currency&api_key={$APIkey}" | jq > newCoinValues.json

echo;
echo -e "*******  Coin  ******  Price ********* 1h% ** 24h% ** 3D% **  7D% **  1M%  ** 3M%  **  6M%";
echo -e "–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––";
while read coin; do

symbol=$(jq .RAW.$coin.$currency.FROMSYMBOL $j | sed s/\"//g;) # Symbol
rawPrice=$(jq .RAW.$coin.$currency.PRICE $j | sed s/\"//g;) # Current RawPrice
price=$(jq .DISPLAY.$coin.$currency.PRICE $j | sed s/\"//g;) # Current Price
change=$(jq .DISPLAY.$coin.$currency.CHANGE24HOUR $j | sed s/\"//g;) # 24h pricechange $currency
changePct=$(jq .DISPLAY.$coin.$currency.CHANGEPCT24HOUR $j | sed s/\"//g;) # 24h pricechange in %
changeHour=$(jq .DISPLAY.$coin.$currency.CHANGEHOUR $j | sed s/\"//g;) # 1h pricechange in USD
changePctHour=$(jq .DISPLAY.$coin.$currency.CHANGEPCTHOUR $j | sed s/\"//g;) # 1h pricechange in $currency

history=$(curl -g -s -X GET "https://min-api.cryptocompare.com/data/v2/histoday?fsym="$coin"&tsym=$currency&limit=182&api_key={$APIkey}");
# History Price-Changes. To round numbers after . use "LC_ALL=C /usr/bin/printf" because of german locale Numberformat using , instad of . ( 6,666).
SIXm=$(printf $history | jq '.Data.Data[0].close');
SIXm=$(awk "BEGIN {a=$SIXm; e=$rawPrice; ep=(e-a)/a*100; printf ep}");
SIXm=$(echo $SIXm | sed "s/","/\./");
#SIXm=$(echo "scale=2; $SIXm/1" | bc)
SIXm=$(LC_ALL=C /usr/bin/printf '%.*f\n' 2 $SIXm);

THREm=$(printf $history | jq '.Data.Data[90].close');
THREm=$(awk "BEGIN {a=$THREm; e=$rawPrice; ep=(e-a)/a*100; printf ep}");
SIXm=$(echo $SIXm | sed "s/","/\./");
#THREm=$(echo "scale=2; $THREm/1" | bc)
THREm=$(LC_ALL=C /usr/bin/printf '%.*f\n' 2 $THREm);

ONEm=$(printf $history | jq '.Data.Data[152].close');
ONEm=$(awk "BEGIN {a=$ONEm; e=$rawPrice; ep=(e-a)/a*100; printf ep}");
ONEm=$(echo $ONEm | sed "s/","/\./");
#ONEm=$(echo "scale=2; $ONEm/1" | bc)
ONEm=$(LC_ALL=C /usr/bin/printf '%.*f\n' 2 $ONEm);

SEVENd=$(printf $history | jq '.Data.Data[175].close');
SEVENd=$(awk "BEGIN {a=$SEVENd; e=$rawPrice; ep=(e-a)/a*100; printf ep}");
SEVENd=$(echo $SEVENd | sed "s/","/\./");
#SEVENd=$(echo "scale=2; $SEVENd/1" | bc)
SEVENd=$(LC_ALL=C /usr/bin/printf '%.*f\n' 2 $SEVENd);

THREd=$(printf $history | jq '.Data.Data[179].close');
THREd=$(awk "BEGIN {a=$THREd; e=$rawPrice; ep=(e-a)/a*100; printf ep}");
THREd=$(echo $THREd | sed "s/","/\./");
#THREd=$(echo "scale=2; $THREd/1" | bc)
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
echo -e "   [enter] - Refresh Price | [h] - Price History Table | [i] - Info | [q] - Quit"
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
    "h") HISTORY ;;
    "H") HOLDINGS ;;
    "c") CURRENCY ;;
    *) TABLE ;;
esac

}

INFO () {
    echo -e "${grey}______________________________________________________________________________________________${reset}";
    echo;echo;
    echo -e "   ${white}Key configuration INFO:${reset}"
    echo -e "   ----------------------"
    echo;
    echo -e "   ${bold}a${reset} - Add Coin"
    echo -e "   ${bold}d${reset} - Delete Coin"
    echo -e "   ${bold}H${reset} - Change Holdings"
    echo
    echo -e "   ${bold}P${reset} - Portfolio Visible"
    echo -e "   ${bold}p${reset} - Portfolio Hidden"
    echo -e "   ${bold}c${reset} - Change Currency"
    echo
    echo -e "   ${bold}q${reset} - Quit"
    echo;echo;echo;
    MENU
}

CURRENCY () {
    if [[ $currency == "USD" ]]; then
        currency="EUR"
        else
        currency="USD"
    fi
    TABLE
}

DELETECOIN () {
    echo -e "${grey}______________________________________________________________________________________________${reset}";
    echo;echo;
    echo -e "   ${white}DELETE COIN${reset}"
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
    # LÖSCHEN mit jq
    # 
    # echo "$jsonFile" | jq --arg delCoin "$dCoin" 'del(.DATA.Coins.[$delCoin])'
}
ADDCOIN () {
    echo -e "${grey}______________________________________________________________________________________________${reset}";
    echo;echo;
    echo -e "   ${white}ADD COIN${reset}"
    echo -e "   --------"
    echo;
    echo -n "   Coinsymbol: "
    read cadd
    if [[ -z $cadd ]]; then
        TABLE
    fi
    cadd=${cadd^^}
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
    echo -e "${grey}______________________________________________________________________________________________${reset}";
    echo;echo;
    echo -e "   ${white}ADD/REMOVE Holdings${reset}"
    echo -e "   -------------------"
    echo;

    coinList=$(echo "$jsonFile" | jq '.DATA.Coins | keys.[]' | sed 's/\"//g')
    count=1;
    while IFS= read -r line; do
    echo "$count. $line"
    coinContainer[$count]="$line"
    count=$((count+1))
    done <<< "$coinList"
    echo
    echo -n "   : "
    read selectedCoin
    if [[ -z $selectedCoin ]]; then
        TABLE
    fi
    echo;echo;
    selectedCoin="${coinContainer[$selectedCoin]}"
    currentAmount=$(echo "$jsonFile" | jq --arg c "$selectedCoin" '.DATA.Coins.[$c].Holding')

    echo -e "   You are currently holding: ${blue}${bold}"$selectedCoin" "$currentAmount" ${reset}"
    echo -e "   ${grey}To add or subtract, simply use a plus or minus sign in front of the value (e.g.+100).${reset}"
    echo;
    echo -n "   Amount: "   
    read amount
    if [[ $amount == *"+"* ]] || [[ $amount == *"-"* ]]; then
        newAmount=$(awk "BEGIN {a="$currentAmount"; n="$amount"; an=a+n; printf an}");
    else
        newAmount="$amount"
    fi

    jsonFile=$(echo "$jsonFile" | jq --arg newHolding $newAmount --arg c "$selectedCoin" '.DATA.Coins.[$c] += {"Holding": $newHolding}')
    echo "$jsonFile" | jq > db.json
   



    TABLE
}
APITEST () {
echo -e "       Testing API Key"
testKey=$(curl -g -s -X GET "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC&tsyms=USD&api_key={$APIkey}"| jq)
resp="$(echo $testKey | grep -o "Error")" 
if [[ "$resp" == "Error" ]]; then
    echo;
    echo -e "${red}${bold}"
    echo -e "       API Error! Either wrong API Key or API just not working :(${reset}"
    echo -n "       Let's try again...press [enter]"
    read enter
    INSTALL
    else
    echo -e "       ${green}${bold}All good!${reset}"
fi
echo;
}
START