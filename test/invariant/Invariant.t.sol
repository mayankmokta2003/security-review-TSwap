// SPDX-License-Identifier:MIT

pragma solidity 0.8.20;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {StdInvariant} from "../../lib/forge-std/src/StdInvariant.sol";
import {PoolFactory} from "../../src/PoolFactory.sol";
import {TSwapPool} from "../../src/TSwapPool.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
 
contract Invariant is StdInvariant, Test {
    // the pools have 2 assets 2 diff tokens we can say
    PoolFactory factory;
    TSwapPool pool;  //pooltoken / weth pool
    ERC20Mock poolToken;
    ERC20Mock weth;
    address user = makeAddr("user");
    

    function setUp() public {

        weth = new ERC20Mock();
        poolToken = new ERC20Mock();
        factory = new PoolFactory(address(weth));
        pool = TSwapPool(factory.createPool(address(poolToken)));

    }

}