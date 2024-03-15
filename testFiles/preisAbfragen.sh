#!/bin/bash

# Symbole Abfragen
curl -g -X GET 'https://api.binance.com/api/v3/ticker/24hr?symbols=["BTCUSDT","BNBUSDT","ADAUSDT","AVAXUSDT","ZILUSDT"]' | jq . > nstat.json
echo;echo "----------";echo;

# Symbole zählen
i=$(jq .[].symbol nstat.json | wc -l)

# Symbole und Preise ausgeben
for (( x=0; $x<$i; x++ )); do
    echo "$(jq .[$x].symbol nstat.json):       $(jq .[$x].lastPrice nstat.json)" | sed s/\"//g;
    echo "Preisänderung: $(jq .[$x].priceChange nstat.json) | % 24h Änderung: $(jq .[$x].priceChangePercent nstat.json)" | sed s/\"//g;
    echo;
done