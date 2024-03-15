#!/bin/bash


history=$(curl -g -s -X GET "https://min-api.cryptocompare.com/data/v2/histoday?fsym="BTC"&tsym=USD&limit=182&api_key={5d9a85bfd7abf848065c6e1d47f9a1a0df5c7713d2c4e53d170c733a80222044}")
printf $history | jq .Data.Data.[0].close 
printf $history | jq .Data.Data.[150]
