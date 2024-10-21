import { groth16 } from "snarkjs";
// import { notifications } from '@mantine/notifications';
// import { TronLinkAdapter } from '@tronweb3/tronwallet-adapters';
// import { Anchor } from '@mantine/core';

import {convertToArray} from './utils';
// import tronPuppyJson from './contracts/TronPuppy.json';
// import minerJson from './contracts/Miner.json';
// import verificationJson from '../circuit/verification_key.json';
// import tronWeb from './provider';


let running = false;

self.onmessage = async (e: MessageEvent<any>) => {
  const { type } = e.data;
  console.log('Worker received message:', e.data);

  if (type === 'start') {
    if (!running) {
      running = true;
      try {
        const { account, hash, target, startNonce } = e.data;
        const [proof, nonce] = await findNonce(account, hash, target, startNonce)

        postMessage({
          "type": "proof",
          "proof": proof,
          "nonce": nonce,
        });
      } finally {
        running = false;
      }
    }
  } else if (type === 'stop') {
    running = false;
    console.log('Worker stopped');
  }
};

const findNonce = async (account: string, currentHash: string, target: string, startNonce: number) => {
  let nonce = startNonce;
  let input = {
    "blockHash": convertToArray(currentHash),
    "address": convertToArray(account),
    "nonce": nonce,
  };
  const minerTarget = parseInt(target);

  async function fetchFileAsUint8Array(fileUrl: string): Promise<Uint8Array> {
    const response = await fetch(fileUrl);
    const arrayBuffer = await response.arrayBuffer();
    return new Uint8Array(arrayBuffer);
  }
  const circuit_wasm = await fetchFileAsUint8Array("/circom/circuit.wasm");
  const final_zkey = await fetchFileAsUint8Array("/circom/final.zkey");

  let start = Date.now();
    while (true) {
    input["nonce"] = nonce;
    if (nonce % 100 === 0) {
      let end = Date.now();
      let diff = (end - start) / 1000;
      let hps = 100 / diff;
      if (nonce === 0) {
        hps = 0;
      }
      console.log("nonce", nonce, hps, "hashes per second");
      start = end;
    }

    const { proof, publicSignals } = await groth16.fullProve(input, circuit_wasm, final_zkey);
    const exportedProof = JSON.parse("[" + await groth16.exportSolidityCallData(proof, publicSignals) + "]");

    const proofTarget = parseInt(exportedProof[3][0], 16);
    const isValid = proofTarget < minerTarget;
    if (!isValid) {
      nonce += 1;
      continue;
    }

    console.log("exportedProof", exportedProof);
    return [exportedProof, nonce];
  }
};

/*


const workerFunc = async (account: str) => {
  tronWeb.setAddress(account);
  let puppyContract = await tronWeb.contract(tronPuppyJson["abi"], tronPuppyJson["address"]);
  let result = await puppyContract.decimals().call();
  console.log(result);

  let minerContract = await tronWeb.contract(minerJson["abi"], minerJson["address"]);
  let params = await loadParams(minerContract);

  let exportedProof = await findNonce(account, params["currentBlockHash"]);

  const parameter = [
    {
      type: "uint256[2]",
      value: exportedProof[0],
    },
    {
      type: "uint256[2][2]",
      value: exportedProof[1],
    },
    {
      type: "uint256[2]",
      value: exportedProof[2],
    },
    {
      type: "uint256[14]",
      value: exportedProof[3],
    }
  ];

  const tx = await tronWeb.transactionBuilder.triggerSmartContract(minerJson["address"], functionSelector, {}, parameter);
  const adapter = new TronLinkAdapter();
  const signedTx = await adapter.signTransaction(tx.transaction);
  const resultTxn = await tronWeb.trx.sendRawTransaction(signedTx);
  console.log(resultTxn);

  // notifications.show({
  //   color: 'green',
  //   title: 'Mine transaction sent',
  //   message: '<Anchor target="_blank" href={getLinkToTransaction(resultTxn.txid)}>Open Transaction</Anchor>'
  // });
};

const verifyProof = async (proof: any, publicSignals: any) => {
  const res = await groth16.verify(verificationJson, publicSignals, proof);
  return res;
}

// };

// //This stringifies the whole function
// let codeToString = workerFunction.toString();
// //This brings out the code in the bracket in string
// let mainCode = codeToString.substring(codeToString.indexOf('{') + 1, codeToString.lastIndexOf('}'));
// //convert the code into a raw data
// let blob = new Blob([mainCode], { type: 'application/javascript' });
// //A url is made out of the blob object and we're good to go
// let worker_script = URL.createObjectURL(blob);

// export default worker_script;
*/