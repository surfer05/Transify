import classes from "../styles/CoinData.module.css";

const Swap = () => {
  return (
    <div className={classes.swap}>
      <h1>Swap</h1>
      <div className={classes.inputAndBtn}>
        <input type="text" disabled value="polygon 5% up"></input>
        <input type="text" disabled value="avalanche 3% up"></input>
        <button>Swap</button>
      </div>
    </div>
  );
};
export default Swap;
