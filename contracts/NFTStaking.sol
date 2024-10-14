// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; 
import "@openzeppelin/contracts/token/ERC721/IERC721.sol"; 
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTStaking is Ownable {

    IERC20 public immutable rewardsToken; 
    IERC721 public immutable nftCollection; 
    uint256 private rewardsPerHour = 100000; 
    mapping (address => Staker) public stakers;

    struct Staker {
        uint256[] stakedTokenIds; 
        uint256 lastUpdatedTime;
        uint256 unclaimedRewards;
    }

    constructor(IERC721 _nftCollection, IERC20 _rewardsToken) Ownable(msg.sender) {
        nftCollection = _nftCollection; 
        rewardsToken = _rewardsToken;
    }

    function stake(uint256[] calldata _tokenIds) external {
        Staker storage staker = stakers [msg.sender]; 
        require(_tokenIds.length > 0, "No tokens to stake");
        for(uint256 i = 0; i <_tokenIds.length; i++){
            uint256 tokenId = _tokenIds[i];
            require(nftCollection.ownerOf(tokenId) == msg.sender, "Can't stake tokens you don't own"); 
            nftCollection.transferFrom(msg.sender, address (this), tokenId);
            staker.stakedTokenIds.push(tokenId);
        }
        updateRewards(msg.sender);
    }

    function withdraw (uint256[] calldata _tokenIds) external {
        Staker storage staker = stakers [msg.sender];
        require(staker.stakedTokenIds.length > 0, "No tokens staked");
        updateRewards (msg.sender);

        for(uint256 i = 0; i < _tokenIds.length; i++){
            uint256 tokenId = _tokenIds[i];
            require(isStaked (msg.sender, tokenId), "Not your staked token");
            
            uint256 index = getTokenIndex(msg.sender, tokenId);
            uint256 lastIndex = staker.stakedTokenIds.length - 1;

            if(index != lastIndex) {
                staker.stakedTokenIds[index]= staker.stakedTokenIds [lastIndex];
            }
            staker.stakedTokenIds.pop();
            nftCollection.transferFrom(address (this), msg.sender, tokenId);
        }
    }

    function claimRewards() external{
        Staker storage staker = stakers [msg.sender];
        uint256 rewards = calculateRewards (msg.sender) + staker.unclaimedRewards;
        require(rewards > 0, "No rewards to claim");
        staker.lastUpdatedTime = block.timestamp;
        staker.unclaimedRewards = 0;
        rewardsToken.transfer (msg.sender, rewards);
    }

    function setRewardsPerHour (uint256 _newValue) external onlyOwner{
        rewardsPerHour = _newValue;
    }

    function isStaked (address _user, uint256 _tokenId) public view returns (bool){
        Staker storage staker = stakers[_user];
        for (uint256 i =0; i< staker.stakedTokenIds.length; i++){
            if(staker.stakedTokenIds[i] == _tokenId){
                return true;
            }
        }
        return false;
    }

    function getTokenIndex (address _user, uint256 _tokenId) public view returns (uint256){ Staker storage staker = stakers[_user];
        for(uint256 i = 0; i < staker.stakedTokenIds.length; i++){
            if(staker.stakedTokenIds[i] == _tokenId){
                return i;
            }
        }
        revert("Token not found");
    }

    function calculateRewards (address _staker) internal view returns (uint256){
        Staker storage staker = stakers[_staker];
        uint256 timePassed = block.timestamp - staker.lastUpdatedTime;
        return (timePassed *rewardsPerHour*staker.stakedTokenIds.length) / 3600;
    }

    function updateRewards (address _staker) internal {
        Staker storage staker = stakers[_staker];
        uint256 rewardsEarned = calculateRewards(_staker);
        staker.unclaimedRewards += rewardsEarned;
        staker.lastUpdatedTime = block.timestamp;
    }
}