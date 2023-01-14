import TableRow from "./TableRow";
import styles from "../styles/CoinData.module.css";
const data = [
  {
    id: "1",
    name: "avalanche",
    number: 3,
    isprofit: false,
    image: "/avax.svg",
  },
  {
    id: "2",
    name: "Polygon",
    number: 4,
    isprofit: true,
    image: "/matic.svg",
  },
  {
    id: "3",
    name: "Ethereum",
    number: 5,
    isprofit: true,
    image: "/eth.svg",
  },
];
const CoinData = () => {
  const tableRow = data.map((row) => (
    <TableRow
      key={row.id}
      id={row.id}
      name={row.name}
      number={row.number}
      image={row.image}
      isprofit={row.isprofit}
    />
  ));
  return (
    <ul className={styles.coinList}>
      <li key="it" className={styles.tableHeader}>
        <div>Name</div>
        <div>Profit/Loss</div>
        <div>No. of coins</div>
      </li>
      {tableRow}
    </ul>
  );
};

export default CoinData;
