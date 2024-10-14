// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract NFTONCHAIN is ERC721URIStorage {
    using Strings for uint256;
    uint256 private _tokenIds;
    address private owner;

    mapping(uint256 => uint256) public tokenIdToNumber;

    constructor() ERC721("NFTONCHAIN", "NFTONCHAIN") {
        owner = msg.sender;
    }

    function generateSVG(uint256 tokenId) public view returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">'
                '<path d="M507.9 998l184.2-531.8H323.6z" fill="#E2B97F" />'
                '<path d="M695.8 321.4h-53.7c29.5 0 53.7-24.2 53.7-53.7S671.6 214 642.1 214c47.1-69.2-72.8-192.3-72.8-192.3s-7.4 70-61.4 92.1c-39.4 16.1-51.4 71.5-55 100.3h-74.3c-29.5 0-53.7 24.2-53.7 53.7s24.2 53.7 53.7 53.7h-56.4c-39.8 0-72.3 32.5-72.3 72.3s32.5 72.3 72.3 72.3h373.6c39.8 0 72.3-32.5 72.3-72.3s-32.5-72.4-72.3-72.4z" fill="#F27596" />'
                '<path d="M507.9 654.5l147.1-70.1m-147.1 161.6l107.1-51" stroke="#1C1C1C" stroke-width="20" fill="none" />'
                '<text font-family="Arial" font-size="100" y="550" x="475" fill="#1C1C1C">', getNumber(tokenId),'</text>'
            '</svg>'
        );

        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getNumber(uint256 tokenId) public view returns (string memory) {
        uint256 number = tokenIdToNumber[tokenId];
        return number.toString();
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        string memory svgData = generateSVG(tokenId);
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "NFTONCHAIN #',
            tokenId.toString(),
            '",',
            '"description": "Collectible IMG",',
            '"image": "',
            svgData,
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function mint() public {
        require(msg.sender == owner, "Only owner can call this function");
        _tokenIds++;
        uint256 newItemId = _tokenIds;
        tokenIdToNumber[newItemId] = 0;
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function incrementNumber(uint256 tokenId) public {
        require(ownerOf(tokenId) == address(0), "Please use an existing token");
        require(
            ownerOf(tokenId) == msg.sender,
            "You must own this token to increment the number!"
        );
        uint256 currentNumber = tokenIdToNumber[tokenId];
        tokenIdToNumber[tokenId] = currentNumber + 1;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}
