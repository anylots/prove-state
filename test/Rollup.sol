// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Rollup} from "../src/Rollup.sol";

contract RollupTest is Test {
    Rollup public rollup;

    function setUp() public {
        rollup = new Rollup();
    }

    function test_Increment() public {}

    function testFuzz_SetNumber(uint256 x) public {}
}
