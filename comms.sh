#!/usr/bin/env bash

curl -X POST http://localhost:9393/users/ -H "Passwords: sithlord" -d '' | jq ''
curl -X POST http://localhost:9393/users/ -d '' | jq ''
curl -X POST http://localhost:9393/users/ -H "Passwords: sithlord" -d '' | jq ''
curl -X GET http://localhost:9393/users -H "Passwords: sithlord" | jq ''

curl -X POST http://localhost:9393/businesses/ -H "Passwords: sithlord" -d check\_in\_timeout=600 -d token="" | jq ''
curl -X POST http://localhost:9393/businesses/ -H "Passwords: sithlord" -d check\_in\_timeout=600 -d token="" | jq ''
curl -X PUT http://localhost:9393/businesses/2/update_token -H "Passwords: sithlord" -d check\_in\_timeout=600 -d token="my_password" | jq ''
curl -X GET http://localhost:9393/businesses -H "Passwords: sithlord" | jq ''

curl -X POST http://localhost:9393/checkins -H "Passwords: sithlord" -d user\_id=1 -d business\_id=1 -d business\_token="my_password" | jq ''
curl -X POST http://localhost:9393/checkins -H "Passwords: sithlord" -d user\_id=1 -d business\_id=2 -d business\_token="my_password" | jq ''
curl -X POST http://localhost:9393/checkins -H "Passwords: sithlord" -d user\_id=1 -d business\_id=2 -d business\_token="my_password" | jq ''
