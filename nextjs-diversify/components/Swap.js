import classes from "../styles/CoinData.module.css";
import { contractAddresses, abi } from "../constants";
// dont export from moralis when using react
import { useMoralis, useWeb3Contract } from "react-moralis";
import { useEffect, useState } from "react";
import { useNotification } from "@web3uikit/core";
import { ethers } from "ethers";

const Swap = (props) => {
  const { Moralis, isWeb3Enabled, chainId: chainIdHex } = useMoralis();
  const chainId = parseInt(chainIdHex);
  const contractAddress =
    chainId in contractAddresses ? contractAddresses[chainId][0] : null;
  console.log(contractAddress);
  const swapLoss = props.swapLoss;
  const { runContractFunction: setNewMaxLossBreareable } = useWeb3Contract({
    abi: abi,
    contractAddress: contractAddress,
    functionName: "setNewMaxLossBreareable",
    params: {
      _percent: swapLoss,
    },
  });
  const { runContractFunction: setterRatio } = useWeb3Contract({
    abi: abi,
    contractAddress: contractAddress,
    functionName: "setterRatio",
    params: {
      chainType: 0,
      chainId: "43113",
      ratioX1000: 11,
    },
  });

  const {
    runContractFunction: transferTokens,
    isLoading,
    isFetching,
  } = useWeb3Contract({
    abi: abi,
    contractAddress: contractAddress,
    functionName: "transferTokens",
    msgValue: "10000000000000000",
    params: {
      chainType: 0,
      chainId: "43113",
      amount: "10000000000000000",
      receipientAddress: "0x9299eac94952235Ae86b94122D2f7c77F7F6Ad30",
      destGasPrice: "30000000000",
    },
  });
  const handleSuccess = async (tx) => {
    try {
      await tx.wait(1);
      //   updateUIValues();
      //   handleNewNotification(tx);
    } catch (error) {
      console.log(error);
    }
  };
  return (
    <div className={classes.swap}>
      <h1>Swap</h1>
      <div className={classes.inputAndBtn}>
        <input type="text" disabled value="polygon 5% up"></input>
        <input type="text" disabled value="avalanche 3% up"></input>
        <button
          className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded ml-auto"
          onClick={async () => {
            await Moralis.enableWeb3();
            await transferTokens({
              // onComplete:
              // onError:
              onSuccess: handleSuccess,
              onError: (error) => console.log(error),
            });
          }}
          disabled={isLoading || isFetching}
        >
          {isLoading || isFetching ? (
            <div className="animate-spin spinner-border h-8 w-8 border-b-2 rounded-full"></div>
          ) : (
            "Swap"
          )}
        </button>
      </div>
    </div>
  );
};
export default Swap;
