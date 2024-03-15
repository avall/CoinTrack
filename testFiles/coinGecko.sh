#!/bin/bash

#curl -X -s 'GET' 'https://api.coingecko.com/api/v3/coins/list?include_platform=false' -H 'accept: application/json' | jq > cg.json


n=$(jq .[].name cg.json | wc -l)


