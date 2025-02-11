// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Rollup} from "../src/Rollup.sol";

contract RollupScript is Script {
    Rollup public rollup;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        rollup = new Rollup();

        vm.stopBroadcast();
    }
}
