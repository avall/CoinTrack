#!/bin/bash
geld=usd;

while read zeile; do
#echo "$zeile,"
track="${track}$zeile,"
done < coingeckoCoins.txt

echo $track

curl -s -X 'GET' "https://api.coingecko.com/api/v3/simple/price?ids="$track"&vs_currencies="$geld"" -H 'accept: application/json' | jq . > iss.json

cat iss.json
echo "----------------"


if grep -q "avalanche-2" iss.json; then
        sed -i s/avalanche-2/avalanche/ iss.json
    else
        echo Avalanche not found
fi
if grep -q "alchemy-pay" iss.json; then
        sed -i s/alchemy-pay/alchemy/ iss.json
    else
        echo Alchemy Pay not found
fi


while read zeile; do

    if [ $zeile == "avalanche-2" ]; then
        zeile="avalanche"
    elif [ $zeile == "alchemy-pay" ]; then
        zeile="alchemy"
    fi

    coinWert=$(jq .$zeile.$geld iss.json);
    echo "$zeile: $coinWert";
done < coingeckoCoins.txt

