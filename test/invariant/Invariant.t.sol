// SPDX-License-Identifier:MIT

pragma solidity 0.8.20;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {StdInvariant} from "../../lib/forge-std/src/StdInvariant.sol";
import {PoolFactory} from "../../src/PoolFactory.sol";
import {TSwapPool} from "../../src/TSwapPool.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {Handler} from "./Handler.t.sol";

contract Invariant is StdInvariant, Test {
    // the pools have 2 assets 2 diff tokens we can say
    PoolFactory factory;
    TSwapPool pool; //pooltoken / weth pool
    ERC20Mock poolToken;
    ERC20Mock weth;
    Handler handler;
    address user = makeAddr("user");

    int256 constant STARTING_X = 100e18;
    int256 constant STARTING_Y = 50e18;

    function setUp() public {
        weth = new ERC20Mock();
        poolToken = new ERC20Mock();
        factory = new PoolFactory(address(weth));
        pool = TSwapPool(factory.createPool(address(poolToken)));

        // create those x and y balances
        // poolToken.mint(address(pool), uint256(STARTING_X));
        // weth.mint(address(pool), uint256(STARTING_Y));

        // poolToken.approve(address(this), type(uint256).max);
        // weth.approve(address(this), type(uint256).max);

        poolToken.mint(address(this), uint256(STARTING_X));
        weth.mint(address(this), uint256(STARTING_Y));

        poolToken.approve(address(pool), type(uint256).max);
        weth.approve(address(pool), type(uint256).max);

        pool.deposit(
            uint256(STARTING_Y),
            uint256(STARTING_Y),
            uint256(STARTING_X),
            uint64(block.timestamp)
        ); 


        handler = new Handler(pool);
        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = handler.deposit.selector;
        selectors[1] = handler.swapPoolTokenForWethBasedOnOutputWeth.selector;
        targetSelector(FuzzSelector({addr: address(handler), selectors: selectors}));
        targetContract(address(handler));
    }

    function statefulFuzz_ConstantProductFormulaStaysTheSame() public {
        // assert??????????
        // ∆x = (β/(1-β)) * x     deltax is change in x???
        assertEq(handler.actualDeltaX(), handler.expectedDeltaX());
    }


}
