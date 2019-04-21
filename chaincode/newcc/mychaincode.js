const shim = require('fabric-shim');
const util = require('util');

var Chaincode = class {
       async Init(stub) {
                let ret = stub.getFunctionAndParameters();
                let args = ret.params;
                let a = args[0];
                let aValue = args[1];
                let b = args[2];
                let bValue = args[3];

                await stub.putState(a,Buffer.from(aValue));
                await stub.putState(b,Buffer.from(bValue));
                console.info(a + " balance is Rs" +aValue);
                console.info(b + " balance is Rs" +bValue);
                return shim.success(Buffer.from("Init successfull!!"));
        }

        Invoke(stub) {
              //  console.info('Transaction ID: ' + stub.getTxID());
                //console.info(util.format('Args: %j', stub.getArgs()));

                let ret = stub.getFunctionAndParameters();
                console.info('Calling function: ' + ret.fcn);
                 let fcn = this[ret.fcn];
                 return fcn(stub,ret.params);
        }

        async Transfer(stub,args){
            let a = args[0];
            let b = args[1];
            let transfer_value = Number(args[2]);
            
            
            let aBalance = await stub.getState(a);
            let bBalance  = await stub.getState(b);
        
            

            aBalance = Number(aBalance) - Number(transfer_value);
            bBalance  = Number(bBalance)  + Number(transfer_value);


            await stub.putState(a,Buffer.from(aBalance.toString()));
            await stub.putState(b,Buffer.from(bBalance.toString()));

            
            return shim.success(Buffer.from("Transfer successfull!"));

        }

        async Query(stub,args){
          let balance = await stub.getState(args[0]);
          let msg = args[0] + " balance is Rs" + balance;
          return shim.success(Buffer.from(msg));
        }



};

shim.start(new Chaincode());
