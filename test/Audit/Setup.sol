// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {StakingAccountant} from "src/StakingAccountant.sol";
import {ValidatorManager} from "src/ValidatorManager.sol";
import {PauserRegistry} from "src/PauserRegistry.sol";
import {StakingManager} from "src/StakingManager.sol";
import {OracleManager} from "src/OracleManager.sol";
import {L1Write} from "src/lib/L1Write.sol";
import {KHYPE} from "src/KHYPE.sol";
import {BaseTest} from "../Base.t.sol";
import {vm} from "./HEVM.sol";
contract Setup {

    BaseTest public baseTest = new BaseTest();


        // Contract instances
    PauserRegistry public pauserRegistry;
    StakingManager public stakingManager;
    KHYPE public kHYPE;
    ValidatorManager public validatorManager;
    OracleManager public oracleManager;
    StakingAccountant public stakingAccountant;

    // Update L1Write address
    address constant L1WRITE = 0x3333333333333333333333333333333333333333;

    // actors
    address public admin;
    address public manager;
    address public sentinel;
    address public operator;

    address public pauser;
    address public unpauser;
    address public pauseAll;

    address public validator1;
    address public user1 = address(111);
    address public user2 = address(222);
    address public user3 = address(333);
    address[] public users = [user1, user2, user3];
    
    address public treasury;




    // Deployment parameters
    uint256 public minStake = 0.001 ether;
    uint256 public maxStake = 1 ether;
    uint256 public stakingLimit = 10_000 ether;
    uint256 public minProcessing = 1 ether;
    uint256 public maxProcessing = 100 ether;
    uint256 public rebalanceThreshold = 500; // 5%
    uint256 public defaultWeightage = 10_000;
    uint256 public maxPerformanceBound = 10_000;
    function _setUp() internal {
        baseTest.setUp();

        pauserRegistry = baseTest.pauserRegistry();
        stakingManager = baseTest.stakingManager();
        kHYPE = baseTest.kHYPE();
        validatorManager = baseTest.validatorManager();
        oracleManager = baseTest.oracleManager();
        stakingAccountant = baseTest.stakingAccountant();


        admin = baseTest.admin();
        manager = baseTest.manager();
        sentinel = baseTest.sentinel();
        operator = baseTest.operator();
        pauser = baseTest.pauser();
        unpauser = baseTest.unpauser();
        pauseAll = baseTest.pauseAll();
        // user = baseTest.user();
        validator1 = address(111);

        treasury = baseTest.treasury();


    ///stakingManager
        stakingManager.setWithdrawalDelay(0);

    ///validator Manager
        updateValidatorManager();
    }

//things to check
//1. donation attack
//2. reentrancy attack
//3. gas limit attack
//4. accurate accounting


function updateValidatorManager() internal {
     vm.startPrank(manager);
        validatorManager.activateValidator(validator1);
        validatorManager.setDelegation(address(stakingManager), validator1);
    vm.stopPrank();

    vm.prank(address(oracleManager));
       validatorManager.updateValidatorPerformance(
            validator1,
            100 ether, // balance
            8000, // uptimeScore (80%)
            7500, // speedScore (75%)
            9000, // integrityScore (90%)
            8500 // selfStakeScore (85%)
        );

    assert(validatorManager.getDelegation(address(stakingManager)) == validator1 );
}


//helper
function between(uint256 value, uint256 low, uint256 high) internal  returns (uint256) {
        if (value < low || value > high) {
            uint256 ans = low + (value % (high - low + 1));
            return ans;
        }
        return value;
    }


}