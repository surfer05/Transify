import classes from "../styles/CoinData.module.css";
import Image from "next/image";
const TableRow = (props) => {
  const marketCap = props.marketCap / 10 ** 6;

  return (
    <>
      <tr key={props.id} className={classes.row}>
        <td>
          <div className={classes.icon}>
            <Image
              loader={() => props.image}
              src={props.image}
              width={20}
              height={20}
              alt="logo"
              className={classes.crypto_icon}
            />
            {props.name}
          </div>
        </td>
        <td>{props.price}</td>
        <td
          className={
            props.priceChange > 0 ? `${classes.profit}` : `${classes.loss}`
          }
        >{`${props.priceChange.toFixed(2)} %`}</td>
        <td>{`${marketCap.toFixed(1)}M`}</td>
      </tr>
    </>
  );
};

export default TableRow;