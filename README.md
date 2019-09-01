# hlf-tunaSupplychain

This Repository utilizes ```fabric-samples/basic-network```

**This is the nodejs version of chaincode implemented from go version of tuna-app owned by Hyperledger-fabric contributors**

Tuna fishing 🎣 supplychain on nodejs for demonstration.

###### Quick Demo:

```
git clone https://github.com/Salmandabbakuti/hlf-tunaSupplychain.git

cd hlf-tunaSupplychain/client

./start.sh

```
for making calls from client Side (From```client/``` directory),run:
```
npm i fabric-ca-client

npm i fabric-network

npm install

node enrollAdmin.js

node registerUser.js

node query.js  // by default queries for All tunas on the ledger. You can simply modify function for other calls

node invoke.js. //Submits a transaction to change tuna owner

```
