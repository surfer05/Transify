import TableRow from "./TableRow";
import styles from "../styles/CoinData.module.css";
const data = [
  {
    id: "1",
    name: "Avalanche",
    number: 3,
    isprofit: false,
    profit: "",
    loss: "2%",
    image: "/avax.svg",
    price: "$17.19",
    marketCap: "$48M",
  },
  {
    id: "2",
    name: "Polygon",
    number: 4,
    isprofit: true,
    profit: "2%",
    loss: "",
    image: "/matic.svg",
    price: "$0.9877",
    marketCap: "$399M",
  },
  {
    id: "3",
    name: "Ethereum",
    number: 5,
    isprofit: true,
    profit: "3%",
    loss: "",
    image: "/eth.svg",
    price: "$1538",
    marketCap: "$187.66M",
  },
];
const CoinData = () => {
  const tableRow = data.map((row) => (
    <TableRow
      id={row.id}
      name={row.name}
      number={row.number}
      image={row.image}
      isprofit={row.isprofit}
      profit={row.profit}
      loss={row.loss}
      price={row.price}
      marketCap={row.marketCap}
    />
  ));
  return (
    // <ul className={styles.coinList}>
    //   <li className={styles.tableHeader}>
    //     <div>Name</div>
    //     <div>Profit/Loss</div>
    //     <div>No. of coins</div>
    //   </li>
    //   {tableRow}
    // </ul>
    <div className={styles.coinList}>
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Last Price</th>
            <th>24h Change</th>
            <th>Market Cap</th>
          </tr>
        </thead>
        <tbody>{tableRow}</tbody>
      </table>
    </div>
  );
};

export default CoinData;
