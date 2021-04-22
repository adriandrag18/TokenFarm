//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.5.0;
// pragma solidity ^0.8.3;

import "./DappToken.sol";
import "./DaiToken.sol";

contract TokenFarm {
    string public name = "Dapp Token Farm";
    DappToken public dappToken;
    DaiToken public daiToken;

    address owner;
    address[] public stakers;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;
    mapping(address => uint) public stakingBalance;

    constructor(DappToken _dappToken, DaiToken _daiToken) public {
        dappToken = _dappToken;
        daiToken = _daiToken;
        owner = msg.sender;
    }

    // Stake
    function stakeTokens(uint _amount) public {
        require(_amount > 0, 'amount can not be 0');
        // Trasnfer Mock Dai tokens to this contract for staking
        daiToken.transferFrom(msg.sender, address(this), _amount);

        // Update staking balance
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        // Add user to stakers array *only* if they haven't staked already
        if(!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
            hasStaked[msg.sender] = true;
        }

        // Update staking status
        isStaking[msg.sender] = true;
    }

    
    // Unstake
    function unstakeTokens(uint _amount) public {
        require(stakingBalance[msg.sender] > 0, "staking can not be 0");
        require(stakingBalance[msg.sender] >= _amount, "Not enough balance");
        daiToken.transfer(msg.sender, _amount);

        stakingBalance[msg.sender] -= _amount;
        if (stakingBalance[msg.sender] == 0)
            isStaking[msg.sender] = false;
    }

    // Issuing Token
    function issueTokens() public  {
        require(msg.sender == owner, "caller must be the owner");

        for (uint i = 0; i < stakers.length; i++) {
            if (stakingBalance[stakers[i]] > 0)
                dappToken.transfer(stakers[i], stakingBalance[stakers[i]]);
        }
    }
}