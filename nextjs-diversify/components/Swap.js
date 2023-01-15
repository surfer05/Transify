import classes from "../styles/CoinData.module.css";
import { contractAddresses, abi } from "../constants";
// dont export from moralis when using react
import { useMoralis, useWeb3Contract } from "react-moralis";
import { useEffect, useState, useRef } from "react";
import { useNotification } from "@web3uikit/core";
import { ethers } from "ethers";

const Swap = (props) => {
  const [inputSwaploss,setInputSwapLoss] = useState();

  const [error, setError] = useState(false);
  const formSubmitHandler = (event) => {
    event.preventDefault();
  };
  const { Moralis, isWeb3Enabled, chainId: chainIdHex } = useMoralis();
  const chainId = parseInt(chainIdHex);
  const contractAddress =
    chainId in contractAddresses ? contractAddresses[chainId][0] : null;
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
    msgValue: inputSwaploss,
    params: {
      chainType: 0,
      chainId: "43113",
      amount: "100000000000000",
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

  let max = [];
  if (props.data) {
    const priceData = props.data.map((data) => {
      return data.market_data.price_change_percentage_24h;
    });
    const maxPrice = Math.max(priceData[0], priceData[1], priceData[2]);
    max = props.data.filter(
      (data) => data.market_data.price_change_percentage_24h == maxPrice
    );
  }

  const inputChangeHandler = (e) => {
    setInputSwapLoss(e.target.value)
  }

  return (
    <div className={classes.swap}>
      <h1>Most Profitable</h1>
      <div className={classes.inputAndBtn}>
        {max != [] && max.map((max) => ( <input
          type="text"
          disabled
          value={`${max.name} ${
            max.market_data.price_change_percentage_24h > 0 ? "up" : "down"
          } by ${max.market_data.price_change_percentage_24h.toFixed(2)} %`}
        ></input>))}
     
         <form className={classes.form} onSubmit={formSubmitHandler}>
          <div className={classes.inputFields}>
            <input onChange={inputChangeHandler} value={inputSwaploss} type="number" placeholder="Amount to swap" />
            <button
        type="submit" 
          className={classes.button}
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
          {/* {error && <p style={{ color: "red" }}>Specify between 0 and 100</p>} */}
        </form>
      </div>
    </div>
  );
};
export default Swap;
