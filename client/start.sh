echo "Removing key from key store..."

rm -rf ./hfc-key-store


# Remove chaincode docker image
docker rmi -f dev-peer0.org1.example.com-mycc-1.0-384f11f484b9302df90b453200cfb25174305fce8f53f4e94d45ee3b6cab0ce9


cd ../basic-network
./start.sh

# Now launch the CLI container in order to install, instantiate chaincode
# and prime the ledger with our 10 cars
docker-compose -f ./docker-compose.yml up -d cli
docker ps -a


echo 'Installing chaincode..'
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode install -n mycc -v 1.0 -p "/opt/gopath/src/github.com/chaincode/newcc" -l "node"

echo 'Instanitating chaincode..'
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode instantiate -o orderer.example.com:7050 -C mychannel -n mycc -l "node" -v 1.0 -c '{"Args":[""]}' --collections-config "/opt/gopath/src/github.com/chaincode/newcc/collection-config.json" -P "OR ('Org1MSP.member','Org2MSP.member')"

echo 'Getting things ready for Chaincode Invocation..should take only 10 seconds..'
sleep 10
echo 'Adding Product on public ledger..'

docker exec -it cli peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n mycc -c '{"function":"addProduct","Args":["publicCollection","MSFTP3","Microsoft Surface Pro3","457","EliteStores"]}'

echo 'Adding Product on private ledger..'

docker exec -it cli peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n mycc -c '{"function":"addProduct","Args":["privateCollection","MSFTP3V","Microsoft Surface Pro3","457","EliteStores"]}'


sleep 3
echo 'Querying Public Product..'

docker exec -e “CORE_PEER_LOCALMSPID=Org1MSP” -e “CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp” cli peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n mycc -c '{"function":"queryProduct","Args":["publicCollection","MSFTP3"]}'

echo 'Querying Private Product..'

docker exec -e “CORE_PEER_LOCALMSPID=Org1MSP” -e “CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp” cli peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n mycc -c '{"function":"queryProduct","Args":["privateCollection","MSFTP3V"]}'


# Starting docker logs of chaincode container

docker logs -f dev-peer0.org1.example.com-mycc-1.0


