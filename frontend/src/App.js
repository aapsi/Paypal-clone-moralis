import { useState, useEffect } from "react";
import "./App.css";
import logo from "./logo.png";
import { Layout, Button } from "antd";
import CurrentBalance from "./componets/CurrentBalance";
import RequestAndPay from "./componets/RequestAndPay";
import AccountDetails from "./componets/AccountDetails";
import RecentActivity from "./componets/RecentActivity";
import { useConnect, useAccount, useDisconnect } from "wagmi";
import { MetaMaskConnector } from "wagmi/connectors/metaMask";
import axios from "axios";

const { Header, Content } = Layout;

function App() {
  const { address, isConnected } = useAccount();
  const { disconnect } = useDisconnect();
  const { connect } = useConnect({
    connector: new MetaMaskConnector(),
  });

  const [name, setName] = useState("...");
  const [balance, setBalance] = useState("...");
  const [dollars, setDollars] = useState("...");
  const [history, setHistory] = useState(null);
  const [requests, setRequests] = useState({ "1": [0], "0": [] });

  function disconnectAndSetNull() {
    disconnect();
    setName("...");
    setBalance("...");
    setDollars("...");
    setHistory(null);
    setRequests({ "1": [0], "0": [] });
  }

  async function getNameAndBalance() {
    const res = await axios.get(`http://localhost:3001/getNameAndBalance`, {
      params: { userAddress: address },
    });

    const response = res.data;
    console.log(response.requests);
    if (response.name[1]) {
      setName(response.name[0]);
    }
    setBalance(String(response.balance));
    setDollars(String(response.dollars));
    setHistory(response.history);
    setRequests(response.requests);
    
  }

  useEffect(() => {
    if (!isConnected) return;
    getNameAndBalance();
  }, [isConnected]);

  return (
    <div className="App">
      <Layout>
        <Header className="header">
          <div className="headerLeft">
            {/* <img src={logo} alt="logo" className="logo" /> */}
            <p style={{
              fontFamily: 'Helvetica, Arial, sans-serif',
              color: '#003087',
              fontWeight: '900', // Set font weight to make it thicker
              fontSize: '24px',
              textTransform: 'uppercase',
              letterSpacing: '2px',
              textAlign: 'center',
              textShadow: '2px 2px 4px rgba(0, 0, 0, 0.5)' // Add a text shadow
            }}>
              Paypal 3.0
            </p>
            {isConnected && (
              <>
                <div
                  className="menuOption"
                  style={{ borderBottom: "1.5px solid black" }}
                >
                  Summary
                </div>
                <div className="menuOption">Activity</div>
                <div className="menuOption">{`Send & Request`}</div>
                <div className="menuOption">Wallet</div>
                <div className="menuOption">Help</div>
              </>
            )}
          </div>
          {isConnected ? (
            <Button type={"primary"} onClick={disconnectAndSetNull}>
              Disconnect Wallet
            </Button>
          ) : (
            <Button type={"primary"} onClick={()=>{
              console.log(requests); connect();
            }}>
              Connect Wallet
            </Button>
          )}
        </Header>
        <Content className="content">
          {isConnected ? (
            <>
              <div className="firstColumn">
                <CurrentBalance dollars={dollars} />
                <RequestAndPay requests={requests} getNameAndBalance={getNameAndBalance}/>
                <AccountDetails
                  address={address}
                  name={name}
                  balance={balance}
                />
              </div>
              <div className="secondColumn">
                <RecentActivity history={history} />
              </div>
            </>
          ) : (
            <div>Please Login</div>
          )}
        </Content>
      </Layout>
    </div>
  );
}

export default App;