cd ..
git clone https://github.com/Salmandabbakuti/hlf-testnet.git


echo "Removing key from key store..."

rm -rf hfc-key-store


# Remove chaincode docker image

STOP AND DELETE THE DOCKER CONTAINERS
docker ps -aq | xargs -n 1 docker stop
docker ps -aq | xargs -n 1 docker rm -v

# DELETE THE OLD DOCKER VOLUMES
docker volume prune

# DELETE OLD DOCKER NETWORKS (OPTIONAL: seems to restart fine without)
docker network prune

echo 'Mounting chaincode..'
cd hlf-testnet
rm -rf chaincode
cd ..
cp -r chaincode hlf-testnet

cd hlf-testnet

./start.sh

docker ps -a


echo 'Installing chaincode..'
docker exec -it cli peer chaincode install -n mycc -v 1.0 -p "/opt/gopath/src/github.com/chaincode/newcc" -l "node"

docker exec -it cl2 peer chaincode install -n mycc -v 1.0 -p "/opt/gopath/src/github.com/chaincode/newcc" -l "node"
docker exec -it cli3 peer chaincode install -n mycc -v 1.0 -p "/opt/gopath/src/github.com/chaincode/newcc" -l "node"


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

docker exec -it cli peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n mycc -c '{"function":"queryProduct","Args":["publicCollection","MSFTP3"]}'

echo 'Querying on Org1 Peer  Private Product..'

docker exec -it cli peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n mycc -c '{"function":"queryProduct","Args":["privateCollection","MSFTP3V"]}'

echo 'Querying on Org2 Peer  Private Product..'

docker exec -it cli2 peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n mycc -c '{"function":"queryProduct","Args":["privateCollection","MSFTP3V"]}'


# Starting docker logs of chaincode container

docker logs -f dev-peer0.org1.example.com-mycc-1.0


