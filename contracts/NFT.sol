// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.27;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract IconsNFT is ERC721, ERC721Enumerable, Ownable(msg.sender) {
    using Strings for uint256;

    uint256 public constant MAX_SUPPLY = 10;
    uint256 public constant COST = 0.000001 ether;
    string public baseURI = "ipfs://Qmefrm33evtSvRE3bz3qBLptidtF3UDXrbdFMhPAuiJfwd/";


    constructor()
        ERC721("IconsNFT", "NFT")
    {}

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }


    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(baseURI, tokenId.toString(), ".json"));
    }

    function safeMint(address to) public payable {
        uint256 currentSupply = totalSupply();
        require(currentSupply < MAX_SUPPLY, "Max supply reached");
        require(msg.value == COST, "Incorrect payment amount");

        _safeMint(to, currentSupply);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
