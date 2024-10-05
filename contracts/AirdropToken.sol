//SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

interface IFakeToken {

function transfer(address to, uint256 _amount) external;
function transferFrom(address from, address to, uint256 amount) external;

}

contract AirdropToken {

    function airdropWithTransfer(IFakeToken _token, address[] memory _addressArray, uint[] memory _amountArray) public { 
        for (uint8 i = 0; i < _addressArray.length; i++){
            _token.transfer(_addressArray[i], _amountArray[i]);
        }
    }

    function airdropWithTransferFrom(IFakeToken _token, address[] memory _addressArray, uint[] memory _amountArray) public { 
        for (uint8 i = 0; i < _addressArray.length; i++){
            _token.transferFrom(msg.sender, _addressArray[i], _amountArray[i]);
        }
    }
}
