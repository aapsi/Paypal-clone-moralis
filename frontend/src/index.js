import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import { configureChains, mainnet, WagmiConfig, createClient } from "wagmi";
import { publicProvider } from "wagmi/providers/public";
import { polygonMumbai } from '@wagmi/chains';

// The code configures interaction with specific blockchain networks. 
// It imports and sets up providers for the Ethereum mainnet and Polygon Mumbai testnet. 
// These providers allow interaction with blockchain networks.
const { provider, webSocketProvider } = configureChains(
  [mainnet, polygonMumbai],
  [publicProvider()]
);

const client = createClient({
  autoConnect: true,
  provider,
  webSocketProvider,
});


const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    {/* This component provides the "wagmi" client as a prop to the rest of the application. */}
    <WagmiConfig client={client}>
        <App />
    </WagmiConfig>
  </React.StrictMode>
);
