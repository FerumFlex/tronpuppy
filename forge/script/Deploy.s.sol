// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/TronPuppy.sol";
import "src/Miner.sol";

contract DeployTokenContract {
    function run() external {
        TronPuppy token = new TronPuppy();
        console.log("Deployed TronPuppy at address: ", address(token));

        Miner miner = new Miner();
        console.log("Deployed Miner at address: ", address(miner));

        token.setMinter(address(miner));
        miner.setToken(address(token));
    }
}