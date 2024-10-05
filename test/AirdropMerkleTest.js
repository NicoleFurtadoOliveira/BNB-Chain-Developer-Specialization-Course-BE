
const {expect} = require('chai');
const keccak256 = require("keccak256"); 
const {MerkleTree} = require("merkletreejs");

function encodeLeaf(address, spots){
    // Same as abi.encodePacked in Solidity
    return new ethers.AbiCoder().encode(
        ["address", "uint64"], // The datatypes of arguments to encode 
        [address, spots] // The actual values
    )
}

describe("Merkle Trees", function () {
    it("should be able to verify if address is in whitelist or not", async function (){
        const testAddresses = await ethers.getSigners();

        const list = [
            encodeLeaf(testAddresses[0].address, 2), 
            encodeLeaf(testAddresses[1].address, 2), 
            encodeLeaf(testAddresses[2].address, 2), 
            encodeLeaf(testAddresses[3].address, 2), 
            encodeLeaf(testAddresses[4].address, 2), 
            encodeLeaf(testAddresses[5].address, 2),
            
        ];

        const merkleTree = new MerkleTree(list, keccak256, {
            hashLeaves: true,
            sortPairs: true,
            sortLeaves: true,
        });

        const root = merkleTree.getHexRoot();

        const airdrop = await ethers.getContractFactory("Airdrop");

        const Airdrop = await airdrop.deploy(root); 
        await Airdrop.waitForDeployment();
        
        for (let i=0; i<6; i++){
            const leaf = keccak256(list[i]);
            const proof = merkleTree.getHexProof(leaf);

            const connectedAirdrop = await Airdrop.connect(testAddresses[i]);

            const verified = await connectedAirdrop.checkwhitelist(proof, 2);
            
            expect(verified).to.equal(true);
        }

        const verifiedInvalid = await Airdrop.checkwhitelist([], 2); 
        expect(verifiedInvalid).to.equal(false);
    })
})