// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "binance-oracle/contracts/mock/VRFConsumerBase.sol"; 
import "binance-oracle/contracts/interfaces/VRFCoordinatorInterface.sol";

//The game uses the binance oracle's Verifiable Random Function (VRF) to retrieve random numbers (called words)
//In order to get random numbers we have to:
//1 check documentation about VRF https://oracle.binance.com/docs/vrf/preparation
//2 look for the VRF contract in the Bsc Scan of Bsc Testnet
//3 in the contract>write contract connect your wallet and click createSubscription to get the subscriptionId in the transaction details > logs area
//This could also be done programatically
//4 use this subscriptionId in the deploy script
//5 look for the VRF Coordinator Contract Address and keyHash and add it to the deploy script
//6 deploy
//7 register your contract in the VRF contract by calling the addConsumer with the subscriptionId and the RPS contract hash

contract RPS is VRFConsumerBase {

    enum StatusEnum {
        WON,
        LOST,
        TIE,
        PENDING
    }

    struct ChallengeStatus{ 
        bool exists; 
        uint256 bet; 
        address player; 
        StatusEnum status;
        uint8 playerChoice; 
        uint8 hostChoice;
    }

    uint256 constant minBet = 0.001 ether;
    uint256 constant maxBet = 0.1 ether;
   
    address owner;

    mapping (address => uint256) public s_currentGame;
    mapping (uint256 => ChallengeStatus) public s_challenges;

    VRFCoordinatorInterface COORDINATOR;

    /*
   * requestRandomWordsRequest function returns a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId / challengeId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
    //Subscription Account id
    uint64 subscriptionId;
    //The keyHash of the node
    bytes32 keyHash;
    //Depends on the number of requested values that you want sent to the fulfillRandomWords() function，
    //For example, for a single request for 2 random numbers, 100.000 is sufficient
    uint32 callbackGasLimit;
    //Minimum number of block confirmations（3 <= requestConfirmations <= 200）
    uint16 requestConfirmations;
    //The number of random numbers you want to return in a single request（ max 500）
    uint8 constant numWords = 1;

    event ChallengeOpened(
        uint256 indexed challengeId, 
        address indexed player, 
        StatusEnum indexed status, 
        uint8 playerChoice,
        uint8 hostchoice
    );

    event ChallengeClosed(
        uint256 indexed challengeId,
        address indexed player, 
        StatusEnum indexed status, 
        uint8 playerChoice,
        uint8 hostChoice
    );

    event Received(address sender, uint256 value);

    constructor(
        uint64 _subscriptionId,
        bytes32 _keyHash,
        address _coordinator,
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations
        ) VRFConsumerBase(_coordinator) {
            owner = msg.sender;
            COORDINATOR = VRFCoordinatorInterface(_coordinator);
            subscriptionId = _subscriptionId;
            keyHash = _keyHash;
            callbackGasLimit = _callbackGasLimit;
            requestConfirmations = _requestConfirmations;
        }

    function getCurrentChallengeStatus(address _player) external view
        returns (
            StatusEnum status,
            uint256 challengeId, 
            address player, 
            uint8 playerChoice, 
            uint8 hostchoice
        ){
        uint256 currentChallengeId = s_currentGame[_player];
        require(s_challenges[currentChallengeId].exists, "Challenge not found"); 
        ChallengeStatus memory challenge = s_challenges[currentChallengeId];


        return(
            challenge.status,
            currentChallengeId, 
            challenge.player,
            challenge.playerChoice, 
            challenge.hostChoice
        );
    }

    function play(uint8 _choice) external payable {
        require(_choice > 0 && _choice < 4, "Choice must be between 1 & 3");
        require(msg.value >= minBet && msg.value <= maxBet, "Invalid bet amount");
        require(msg.value * 2 <= address (this).balance, "Insufficient balance on the contract");
        uint256 challengeId = openChallenge(msg.sender, _choice, msg.value);
        s_currentGame[msg.sender] = challengeId;
    }

    function openChallenge (address _player, uint8 _choice, uint256 _bet) internal returns (uint256 challengeId) {
        challengeId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations, 
            callbackGasLimit,
            numWords
        );

        s_challenges[challengeId] = ChallengeStatus({
            exists: true,
            bet: _bet,
            player: _player,
            status: StatusEnum.PENDING, 
            playerChoice: _choice,
            hostChoice: 0
        });

        emit ChallengeOpened(
            challengeId,
            _player,
            StatusEnum.PENDING,
            _choice,
            0
        );

        return challengeId; 
    } 


    function determinewinner (uint8 value1, uint8 value2) internal pure returns (StatusEnum){ 
        if (value1 == value2) {
            return StatusEnum.TIE;
        } else if (
            (value1 == 1 && value2 == 3 ) ||
            (value1 == 2 && value2 == 1) ||
            (value1 == 3 && value2 == 2)
        ){
            return StatusEnum.WON;
        }
        return StatusEnum.LOST;
    }

    function fulfillRandomWords(uint256 challengeId, uint256[] memory _randomWords) internal override {
        ChallengeStatus storage challenge = s_challenges[challengeId];
        require(challenge.exists, "Challenge not found");

        //Insures 1 <= random number <= 3 
        uint8 hostChoice = uint8((_randomWords[0] % 3 ) + 1);

        StatusEnum status = determinewinner(challenge.playerChoice, hostChoice);

        challenge.hostChoice = hostChoice; 
        challenge.status = status;

        if(status == StatusEnum.WON) {
            payable(challenge.player).transfer(challenge.bet * 2);
        } else if(status == StatusEnum.TIE) {
            payable(challenge.player).transfer(challenge.bet);
        }
        
        emit ChallengeClosed(
            challengeId,
            challenge.player,
            status,
            challenge.playerChoice,
            hostChoice
        );
    }

    function withdraw() external{
        require(msg.sender == owner, "Only owner can withdraw"); 
        payable(owner).transfer(address (this).balance);
    }
   
    receive() external payable{
        emit Received(msg.sender, msg.value);
    }
}