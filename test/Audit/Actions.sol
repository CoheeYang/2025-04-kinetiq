// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {StakingAccountant} from "src/StakingAccountant.sol";
import {ValidatorManager} from "src/ValidatorManager.sol";
import {PauserRegistry} from "src/PauserRegistry.sol";
import {StakingManager} from "src/StakingManager.sol";
import {OracleManager} from "src/OracleManager.sol";
import {L1Write} from "src/lib/L1Write.sol";
import {KHYPE} from "src/KHYPE.sol";
import {vm} from "./HEVM.sol";
import {Setup} from "./Setup.sol";
contract Actions is Setup {

    uint256 public totalHype;
    mapping (address => uint256) public userStakes;
    mapping (address => uint256) public userTokens;
    

    function E2E() public{
        //1.账目记得对
        assert(stakingManager.totalStaked() ==totalHype);




    }


    function stake(uint256 stakeAmount,uint8 index) public {
        //precondtions
        require(stakeAmount >= minStake && stakeAmount <= maxStake, "Stake amount out of bounds");
        uint256 userIndex = uint256(index) % users.length; 
        address user = users[userIndex];

        //before
        uint256 userStake_before =userStakes[user];
        uint256 userToken_before = userTokens[user]; 


        //action
        vm.deal(user, stakeAmount);
        vm.prank(user);
        stakingManager.stake{value: stakeAmount}();


        //after
        uint256 userStake_after =userStakes[user];
        uint256 userToken_after = userTokens[user];


        //assertions
        totalHype += stakeAmount;

        //1. stake总数要对的上这里的account
        assert(stakingManager.totalStaked() ==totalHype);

        //2. 用户确实得到了对应的token
        assert(userToken_after == userToken_before + stakeAmount);

        //3. 用户的stake也要增加
        assert(userStake_after == userStake_before + stakeAmount);
       
    }

}