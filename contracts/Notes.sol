//SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract Note {
    string public note;

    function setNote(string memory _note) public {
        note = _note;
    }

    function getNote() public view returns (string memory) {
        return note;
    }
}