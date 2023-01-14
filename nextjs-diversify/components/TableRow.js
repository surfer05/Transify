import classes from "../styles/CoinData.module.css";
import Image from "next/image";
const TableRow = (props) => {
  return (
    <li key={props.id} className={classes.row}>
      <div className={classes.icon}>
        <Image src={props.image} width={20} height={20} alt="logo" />
        {props.name}
      </div>
      <div className={props.isprofit ? `${classes.profit}` : `${classes.loss}`}>
        loss
      </div>
      <div>{props.number}</div>
    </li>
  );
};

export default TableRow;
