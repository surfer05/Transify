// This file is to show what making a connect button looks like behind the scenes!
import classes from "../styles/Header.module.css";
import { useEffect, useState } from "react";
import { useMoralis } from "react-moralis";
import { useRef } from "react";

// Top navbar
export default function ManualHeader(props) {
  const {
    enableWeb3,
    isWeb3Enabled,
    isWeb3EnableLoading,
    account,
    Moralis,
    deactivateWeb3,
  } = useMoralis();

  useEffect(() => {
    if (
      !isWeb3Enabled &&
      typeof window !== "undefined" &&
      window.localStorage.getItem("connected")
    ) {
      enableWeb3();
      // enableWeb3({provider: window.localStorage.getItem("connected")}) // add walletconnect
    }
  }, [isWeb3Enabled]);
  // no array, run on every render
  // empty array, run once
  // dependency array, run when the stuff in it changesan

  useEffect(() => {
    Moralis.onAccountChanged((account) => {
      console.log(`Account changed to ${account}`);
      if (account == null) {
        window.localStorage.removeItem("connected");
        deactivateWeb3();
        console.log("Null Account found");
      }
    });
  }, []);

  const inputRef = useRef();
  const [error, setError] = useState(false);
  const formSubmitHandler = (event) => {
    event.preventDefault();
    const inputSwaploss = inputRef.current.value;
    console.log(inputSwaploss);
    inputRef.current.value = "";
    if (inputSwaploss > 100 || inputSwaploss < 0) {
      setError(true);
      return;
    } else {
      setError(false);
    }
    props.onAddSwapLoss(inputSwaploss);
  };

  return (
    <nav className="p-5 border-b-2">
      <ul className={classes.list}>
        <li className={classes.swaploss}>
          <form onSubmit={formSubmitHandler} className={classes.form}>
            <div className={classes.inputFields}>
              <input ref={inputRef} type="number" placeholder="Swaploss (%)" />
              <button type="submit" className={classes.button}>
                Submit
              </button>
            </div>
            {error && <p style={{ color: "red" }}>Specify between 0 and 100</p>}
          </form>
        </li>
        <li className={"flex flex-row"}>
          {account ? (
            <div className="ml-auto py-2 px-4 text-white">
              Connected to {account.slice(0, 6)}...
              {account.slice(account.length - 4)}
            </div>
          ) : (
            <button
              onClick={async () => {
                // await walletModal.connect()
                const ret = await enableWeb3();
                if (typeof ret !== "undefined") {
                  // depends on what button they picked
                  if (typeof window !== "undefined") {
                    window.localStorage.setItem("connected", "injected");
                    // window.localStorage.setItem("connected", "walletconnect")
                  }
                }
              }}
              disabled={isWeb3EnableLoading}
              className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded ml-auto"
            >
              Connect Wallet
            </button>
          )}
        </li>
      </ul>
    </nav>
  );
}
