require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.27",
  networks: {
    bscmainnet: {
      url: process.env.MAINNET_RPC,
      accounts: [process.env.PRIVATE_KEY], 
      gasPrice: 20000000000,
    },
    bsctestnet: {
      url: process.env.TESTNET_RPC,
      accounts: [process.env.PRIVATE_KEY],
      gasPrice: 21000000000
    }
  },
  etherscan: {
    apiKey: {
      bscTestnet: [process.env.BSCSCAN_API_KEY]
    }
  },
  sourcify: {
    enabled: true
  }
};
