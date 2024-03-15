curl -g -X GET 'https://api.binance.com/api/v3/ticker/price?symbols=["BTCUSDT","BNBUSDT","ADAUSDT"]' | jq . > c.json

#24h änderungen inkl. aktueller preis
curl -g -X GET 'https://api.binance.com/api/v3/ticker/24hr?symbols=["BTCUSDT","BNBUSDT","ADAUSDT"]' | jq



# Gute Seite
https://www.baeldung.com/linux/jq-command-json

# Aus Array auslesen
jq '.[].symbol' c.json 

# Einzelnes Array auslesen
jq '.[1].symbol' c.json 
jq '.[1].price' c.json 



# Symbol und Preis ausgeben
echo "$(jq .[0].symbol c.json): $(jq .[0].lastPrice c.json)"