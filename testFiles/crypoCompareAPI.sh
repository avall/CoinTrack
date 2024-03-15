#!/bin/bash


curl -g -s -X GET 'https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC,ETH,AVAX,ADA,KMD,ACH&tsyms=USD&api_key={5d9a85bfd7abf848065c6e1d47f9a1a0df5c7713d2c4e53d170c733a80222044}' | jq


