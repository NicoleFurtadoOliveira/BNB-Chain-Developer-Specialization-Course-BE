
// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("RPSModule", (m) => {

    const subscriptionId = 341;
    const keyHash = "0x617abc3f53ae11766071d04ada1c7b0fbd49833b9542e9e91da4d3191c70cc80"; 
    const vrfCoordinatorAddress = "0xa2d23627bC0314f4Cbd08Ff54EcB89bb45685053";
    const callbackGasLimit = 1000000;
    const requestConfirmations = 3;

    const deployedContract = m.contract("RPS", [subscriptionId, keyHash, vrfCoordinatorAddress, callbackGasLimit, requestConfirmations]);

    return { deployedContract };
});