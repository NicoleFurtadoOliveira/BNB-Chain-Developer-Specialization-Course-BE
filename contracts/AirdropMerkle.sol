
//SPDX-License-Identifier: MIT
pragma solidity 0.8.27;
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Airdrop {
    bytes32 public merkleRoot;

    constructor(bytes32 _merkleRoot) {
        merkleRoot = _merkleRoot;
    }
    
    function checkwhitelist(bytes32[] calldata proof, uint64 maxAllowanceToMint) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encode(msg.sender, maxAllowanceToMint)); 
        bool verified = MerkleProof.verify(proof, merkleRoot, leaf);
        return verified;
    }
}