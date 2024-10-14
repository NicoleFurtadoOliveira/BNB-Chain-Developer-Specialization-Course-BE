
// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("NFTStakingModule", (m) => {

    const _nftCollection = "0x3014032350Cfb83c19Ec140501c7139f05133C5a";
    const _rewardsToken = "0x891F110EEAC61c0D7c43476097294687a7EdDc6A"; 

    const deployedContract = m.contract("NFTStaking", [_nftCollection, _rewardsToken]);

    return { deployedContract };
});