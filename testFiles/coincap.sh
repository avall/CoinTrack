#!/bin/bash

curl --location 'api.coincap.io/v2/assets/bitcoin/history?interval=d1'

curl --location 'api.coincap.io/v2/assets/alchemy-pay/history?interval=d1' | jq