
// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("BEP20BasicModule", (m) => {

    const name = "BEP20Basic"; 
    const symbol = "BEP20";

    const deployedContract = m.contract("BEP20Basic", [name, symbol]);

    return { deployedContract };
});