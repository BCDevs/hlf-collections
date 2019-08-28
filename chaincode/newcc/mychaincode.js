'use strict';
const shim = require('fabric-shim');
const util = require('util');

let Chaincode = class {

    async Init(stub) {
    console.info('=========== Instantiated tuna supplychain chaincode ===========');
    return shim.success();
  }

  
  async Invoke(stub) {
    let ret = stub.getFunctionAndParameters();
    console.info(ret);

    let method = this[ret.fcn];
    if (!method) {
      console.error('no function of name:' + ret.fcn + ' found');
      throw new Error('Received unknown function ' + ret.fcn + ' invocation');
    }
    try {
      let payload = await method(stub, ret.params);
      return shim.success(payload);
    } catch (err) {
      console.log(err);
      return shim.error(err);
    }
  }

  async queryTuna(stub, args) {
    if (args.length != 1) {
      throw new Error('Incorrect number of arguments. Expecting CarNumber ex: CAR01');
    }
    let tunaId = args[0];

    let tunaAsBytes = await stub.getState(tunaId); 
    if (!tunaAsBytes || tunaAsBytes.toString().length <= 0) {
      throw new Error(tunaId + ' does not exist: ');
    }
    console.log(tunaAsBytes.toString());
    return tunaAsBytes;
  }

  async initLedger(stub, args) {
    console.info('============= START : Initialize Ledger ===========');
    const tunas = [
            {Vessel: "923F", Location: "67.0006, -70.5476", Timestamp: "1504054225", Holder: "Miriam"},
            {Vessel: "M83T", Location: "91.2395, -49.4594", Timestamp: "1504057825", Holder: "Dave"},
	    {Vessel: "T012", Location: "58.0148, 59.01391", Timestamp: "1493517025", Holder: "Igor"},
            {Vessel: "P490", Location: "-45.0945, 0.7949", Timestamp: "1496105425", Holder: "Amalea"},
	    {Vessel: "S439", Location: "-107.6043, 19.5003", Timestamp: "1493512301", Holder: "Rafa"},
	    {Vessel: "J205", Location: "-155.2304, -15.8723", Timestamp: "1494117101", Holder: "Shen"},
	    {Vessel: "S22L", Location: "103.8842, 22.1277", Timestamp: "1496104301", Holder: "Leila"},
	    {Vessel: "EI89", Location: "-132.3207, -34.0983", Timestamp: "1485066691", Holder: "Yuan"},
	    {Vessel: "129R", Location: "153.0054, 12.6429", Timestamp: "1485153091", Holder: "Carlo"},
	    {Vessel: "49W4", Location: "51.9435, 8.2735", Timestamp: "1487745091", Holder: "Fatima"}
	
        ];

    for (let i = 0; i < tunas.length; i++) {
      tunas[i].docType = 'tuna';
      await stub.putState('Tuna' + i, Buffer.from(JSON.stringify(tunas[i])));
      console.info('Added <--> ', tunas[i]);
    }
    console.info('============= END : Initialize Ledger ===========');
  }

  async addTuna(stub, args) {
    console.info('============= START : Adding Tuna===========');
    if (args.length != 5) {
      throw new Error('Incorrect number of arguments. Expecting 5');
    }

    var tuna = {
      docType: 'tuna',
      Vessel: args[1],
      Location: args[2],
      TimeStamp: args[3],
      Holder: args[4]
    };

    await stub.putState(args[0], Buffer.from(JSON.stringify(tuna)));
    console.info('============= END : Tuna Added===========');
  }

  async queryAllTunas(stub, args) {

    let startKey = 'Tuna0';
    let endKey = 'Tuna999';

    let iterator = await stub.getStateByRange(startKey, endKey);

    let allResults = [];
    while (true) {
      let res = await iterator.next();

      if (res.value && res.value.value.toString()) {
        let jsonRes = {};
        console.log(res.value.value.toString('utf8'));

        jsonRes.Key = res.value.key;
        try {
          jsonRes.Record = JSON.parse(res.value.value.toString('utf8'));
        } catch (err) {
          console.log(err);
          jsonRes.Record = res.value.value.toString('utf8');
        }
        allResults.push(jsonRes);
      }
      if (res.done) {
        console.log('end of data');
        await iterator.close();
        console.info(allResults);
        return Buffer.from(JSON.stringify(allResults));
      }
    }
  }

  async changeTunaOwner(stub, args) {
    console.info('============= START : changing Tuna Owner ===========');
    if (args.length != 2) {
      throw new Error('Incorrect number of arguments. Expecting 2');
    }

    let tunaAsBytes = await stub.getState(args[0]);
    let tuna = JSON.parse(tunaAsBytes);
    tuna.Holder = args[1];

    await stub.putState(args[0], Buffer.from(JSON.stringify(tuna)));
    console.info('============= END : changed Tuna Owner ===========');
  }
};

shim.start(new Chaincode());
