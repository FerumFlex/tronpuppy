import { useEffect, useState, useMemo } from "react";

// @ts-ignore
import TronWeb from 'tronweb';

import { Paper, Title, Flex, Button, Anchor, Tooltip, Text, Badge } from '@mantine/core';
import { notifications } from '@mantine/notifications';

import { TronLinkAdapter } from '@tronweb3/tronwallet-adapters';
import tronWeb from '../provider';
import tronPuppyJson from '../contracts/TronPuppy.json';
import minerJson from '../contracts/Miner.json';
import {getLinkToTransaction, sleep} from '../utils';
import workerUrl from "../worker?worker&url";
import { WalletActionButton } from '@tronweb3/tronwallet-adapter-react-ui';
import CopyButton from "@/components/CopyButton";


const functionSelector = "mine(uint256[2],uint256[2][2],uint256[2],uint256[14])";

const NILE_CHAIN_ID = "0xcd8690dc";


const loadParams = async (minerContract: any) => {
  const result = await minerContract.getParams().call();
  return {
    currentDifficulty: result[0].toString(),
    epoch: result[1].toString(),
    minePerBlock: result[2].toString(),
    currentTarget: result[3].toString(),
    countInPeriod: result[4].toString(),
    numBlobksMined: result[5].toString(),
    periodStartBlockNumber: result[6].toString(),
    currentBlockHash: result[7]
  }
};


const loadAllParams = async(adapter: any, account: string) => {
  let network = await adapter.network();
``
  let minerContract = tronWeb.contract(minerJson["abi"], minerJson["address"]);
  let params = await loadParams(minerContract);

  let puppyContract = tronWeb.contract(tronPuppyJson["abi"], tronPuppyJson["address"]);
  let trxAmount = await puppyContract.balanceOf(account).call();

  let balance = await tronWeb.trx.getBalance(account);

  return [
    network,
    params,
    trxAmount,
    balance
  ];
}


export function HomePage() {
  const [readyState, setReadyState] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [account, setAccount] = useState('');
  const [tokenAmount, setTokenAmount] = useState(0);
  const [params, setParams] = useState<any>(null);
  const [worker, setWorker] = useState<any>(null);
  const [network, setNetwork] = useState<any>(null);
  const [accountBalance, setAccountBalance] = useState(0);
  const adapter = useMemo(() => new TronLinkAdapter(), []);

  useEffect(() => {
    if ((account === "") || (account === null)) return;

    tronWeb.setAddress(account);

    const innerLoadParams = async () => {
      setIsLoading(true);
      try {
        const [network, params, trxAmount, balance] = await loadAllParams(adapter, account);
        setNetwork(network);
        setParams(params);
        setTokenAmount(trxAmount / (10 ** 18));
        setAccountBalance(balance / (10 ** 6));
      } finally {
        setIsLoading(false);
      }
    };

    if (params === null) {
      innerLoadParams();
    }

    const intervalId = setInterval(async () => {
      await innerLoadParams();
    }, 5000);
    return () => clearInterval(intervalId);
  }, [account])

  useEffect(() => {
    setReadyState(adapter.readyState);
    setAccount(adapter.address!);

    adapter.on('connect', () => {
      console.log(`Connected to ${adapter.address}`);
      setAccount(adapter.address!);
    });

    adapter.on('readyStateChanged', (state) => {
      setReadyState(state);
    });

    adapter.on('accountsChanged', (data) => {
      console.log(`Account changed to ${data}`);
      setAccount(data);
    });

    return () => {
      adapter.removeAllListeners();
    };
  }, []);

  useEffect(() => {
    return () => {
      if (worker) worker.terminate();
    };
  }, [worker]);

  const startWorker = async () => {
    const sendStartMessage = async (worker: any, params: any, nonce: number) => {
      const account_hex = "0x" + TronWeb.address.toHex(account).slice(2)
      const data = {
        type: "start",
        account: account_hex,
        hash: params["currentBlockHash"],
        target: params["currentTarget"],
        startNonce: nonce
      }
      console.log("Sending data to worker:", data);
      worker.postMessage(data);
      setWorker(worker);
    };

    if (!worker) {
      tronWeb.setAddress(account);

      let minerContract = await tronWeb.contract(minerJson["abi"], minerJson["address"]);
      let params = await loadParams(minerContract);
      setParams(params);

      const newWorker = new Worker(workerUrl, { type: 'module' })

      newWorker.onmessage = async (e) => {
        console.log('from worker', e.data); // Receive messages from the worker

        const { proof, nonce } = e.data;

        const parameter = [
          {
            type: "uint256[2]",
            value: proof[0],
          },
          {
            type: "uint256[2][2]",
            value: proof[1],
          },
          {
            type: "uint256[2]",
            value: proof[2],
          },
          {
            type: "uint256[14]",
            value: proof[3],
          }
        ];

        try {
          const result = await tronWeb.transactionBuilder.estimateEnergy(
            minerJson["address"],
            functionSelector,
            {},
            parameter,
          );
          console.log(result);

          const tx = await tronWeb.transactionBuilder.triggerSmartContract(minerContract["address"], functionSelector, {}, parameter);
          const signedTx = await adapter.signTransaction(tx.transaction);
          const resultTxn = await tronWeb.trx.sendRawTransaction(signedTx);
          console.log(resultTxn);

          notifications.show({
            color: 'green',
            title: 'Mine transaction sent',
            message: <Anchor target="_blank" href={getLinkToTransaction(resultTxn.txid)}>Open Transaction</Anchor>
          });

          await sleep(10_000);

          const [network, params, trxAmount, balance] = await loadAllParams(adapter, account);
          setNetwork(network);
          setParams(params);
          setTokenAmount(trxAmount / (10 ** 18));
          setAccountBalance(balance / (10 ** 6));

          await sendStartMessage(newWorker, params, 0);
        } catch (e: any) {
          const errorMessage = e.toString();
          console.error(e);

          if (errorMessage.includes("REVERT opcode executed") || errorMessage.includes("org.tron.core.vm.program.Program$OutOfTimeException")) {
            const [network, params, trxAmount, balance] = await loadAllParams(adapter, account);
            setNetwork(network);
            setParams(params);
            setTokenAmount(trxAmount / (10 ** 18));
            setAccountBalance(balance / (10 ** 6));

            await sendStartMessage(newWorker, params, nonce + 1);
          } else {
            notifications.show({
              color: 'red',
              title: 'Worker stopped - Error',
              message: errorMessage
            });
            setWorker(null);
          }
        }

      };

      await sendStartMessage(newWorker, params, 0);
    }
  };

  const stopWorker = () => {
    if (worker) {
      worker.postMessage({ type: 'stop' }); // Signal worker to stop
      worker.terminate();
      setWorker(null);
    }
  };

  const switchToNile = async () => {
    await adapter.switchChain(NILE_CHAIN_ID);
  }

  return (
    <>
      <Paper maw={500} mx={"auto"} p="xl" withBorder radius="xl" style={{ marginBottom: 20 }}>
        <Flex direction="column" gap={10} justify={"left"}>
          <Flex
            justify="center"
            align="center"
            my={"20"}
          >
            <Title>
              <Flex justify={"center"} align={"center"}>
                TronPuppy meme
                <Badge m={5}>Beta</Badge>
              </Flex>
            </Title>
          </Flex>

          <WalletActionButton></WalletActionButton>

          {network && params && account ? (
            <>
              <Flex gap={5}>
                <Flex><strong>Address:</strong></Flex>
                <Flex align={"center"}>
                  <CopyButton text={account} />
                  <Anchor href={`https://nile.tronscan.org/#/address/${account}`} target="_blank">{account}</Anchor>
                </Flex>
              </Flex>

              {(network.networkType === 'Nile') ? (
                <>
                  <Flex gap={5}>
                    <Flex><strong>Balance:</strong></Flex>
                    <Flex>{accountBalance.toLocaleString()} TRX <Anchor mx={10} href="https://nileex.io/join/getJoinPage" target="_blank">Get test TRX</Anchor></Flex>
                  </Flex>

                  {tokenAmount > 0 && (
                    <Flex gap={5}>
                      <Flex><strong>Amount:</strong></Flex>
                      <Flex>{tokenAmount.toLocaleString()} TPUPPY</Flex>
                    </Flex>
                  )}

                  <Paper withBorder p={10}>
                    <Flex gap={5}>
                      <Flex><strong>Block&nbsp;hash:</strong></Flex>
                      <Flex>
                        <Tooltip label={params["currentBlockHash"]}>
                          <Text truncate={"end"} w={200}>
                            {params["currentBlockHash"]}
                          </Text>
                        </Tooltip></Flex>
                    </Flex>

                    <Flex gap={5}>
                      <Flex><strong>Block&nbsp;number:</strong></Flex>
                      <Flex>{params["numBlobksMined"]}</Flex>
                    </Flex>

                    <Flex gap={5}>
                      <Flex><strong>Difficulty:</strong></Flex>
                      <Flex>{params["currentDifficulty"]}</Flex>
                    </Flex>

                    <Flex gap={5}>
                      <Flex><strong>Epoch:</strong></Flex>
                      <Flex>{params["epoch"]}</Flex>
                    </Flex>

                    <Flex gap={5}>
                      <Flex><strong>Tokens per block:</strong></Flex>
                      <Flex>{(params["minePerBlock"] / 10 ** 18).toLocaleString()}</Flex>
                    </Flex>
                  </Paper>

                  <Flex gap={5}>
                    <Button size="xs" color="blue" onClick={startWorker} disabled={!!worker}>Start mining</Button>
                    <Button size="xs" color="red" onClick={stopWorker} disabled={!worker}>Stop mining</Button>
                  </Flex>
                </>
              ) : (
                <>
                  <Flex gap={5} direction={"row"} align="center">
                    <Flex><strong>Wrong network:</strong></Flex>
                    <Flex justify={"center"} direction={"row"} align="center">
                      {network.networkType}
                      <Button mx={10} onClick={switchToNile}>Switch</Button>
                    </Flex>
                  </Flex>
                </>
              )}
            </>
          ) : (
            <>
              {account && (
                <Flex gap={5}>
                  <Flex><strong>Loading:</strong></Flex>
                  <Flex>...</Flex>
                </Flex>
              )}
            </>
          )}
        </Flex>
      </Paper>
    </>
  );
}
