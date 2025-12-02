## High

[H-1] TITLE (Root Cause + Impact) Incorrect fee calculation in the function `TSwapPool::getInputAmountBasedOnOutput` causes protocol to take way too many tokens fron user.

Description: In function `TSwapPool::getInputAmountBasedOnOutput` the calculation is totally wrong in my opinion because you want your protocol to give 0.03% of every swap to the liquidators but this function will actually returns wrong value of input based of output.

Impact: The protocol takes way too many fees from the user

Proof of Concept: COnsider adding the below test to your `TSwapPoolTest`

<details>
<summary>PoC</summary>

```javascript
function testGetInputAmountBasedOnOutputChargesAlot() public {
        vm.startPrank(liquidityProvider);
        weth.approve(address(pool),100e18);
        poolToken.approve(address(pool), 100e18);
        pool.deposit(100e18, 100e18, 100e18, uint64(block.timestamp));
        uint256 inputReservesWeth = weth.balanceOf(address(pool));
        uint256 outputReservesPToken = poolToken.balanceOf(address(pool));
        uint256 expectedInputWeth = 11144544745347152568;
        uint256 actualInputWeth = pool.getInputAmountBasedOnOutput(10e18, inputReservesWeth, outputReservesPToken);
        console.log("the actual input amount is as of 10e18Weth is:",actualInputWeth);
        assert(actualInputWeth > expectedInputWeth);
        vm.stopPrank();
    }
```

</details>

Recommended Mitigation:



## Medium

[M-1] TITLE (Root Cause + Impact) In `TSwapPool::deposit` the deadline check for the transaction is missing.

Description: the function `TSwapPool::deposit` has a parameter `uint64 deadline` which is not used anywhere plus according to your natspac this parameter should ensure that no deposit transaction will continue if the deadline has passed. However the paramaeter is not used or updated so anytime the deposit can happen even after the transaction deadline as well which can even lead to `MEV attack`

Impact: Transactions can be send when market conditions are unfavourable to deposit, even when adding a deadline parameter.

Proof of Concept: The `uint64 deadline` parameter is unused.

Recommended Mitigation: Consider making following changes to the function `TSwapPool::deposit`:

```diff
function deposit(
        uint256 wethToDeposit,
        uint256 minimumLiquidityTokensToMint,
        uint256 maximumPoolTokensToDeposit,
        uint64 deadline
    )
        external
+        revertIfDeadlinePassed(deadline)
        revertIfZero(wethToDeposit)
        returns (uint256 liquidityTokensToMint)
    {
```


## Low

[S-#] TITLE (Root Cause + Impact) In `TSwapPool::_addLiquidityMintAndTransfer` function the event emitted is backwords which is incorrect

Description: In the function `TSwapPool::_addLiquidityMintAndTransfer` there is emitted event  `LiquidityAdded` in which the order of events emitted is incorrect as the second one should be on the third place and the third one should be on the second place.

Impact: This could lead to getting wrong values off-chain or on frontend if we call this event or get data.

Recommended Mitigation: Consider adding this code to your `TSwapPool::_addLiquidityMintAndTransfer` function:

```diff
-    emit LiquidityAdded(msg.sender, poolTokensToDeposit, wethToDeposit);
+    emit LiquidityAdded(msg.sender, wethToDeposit, poolTokensToDeposit);
```





[I-1] TITLE (Root Cause + Impact) The error `PoolFactory::PoolFactory__PoolDoesNotExist` is not used in the contract, hence should be removed.

```diff

contract PoolFactory {
    error PoolFactory__PoolAlreadyExists(address tokenAddress);
-    error PoolFactory__PoolDoesNotExist(address tokenAddress);

```




[I-2] TITLE (Root Cause + Impact) Lacking zero address check at constructor in `PoolFactory`

```diff

constructor(address wethToken) {
+        require(wethToken != address(0), "Weth Address is zero")
        i_wethToken = wethToken;
    }

```



[I-3] TITLE (Root Cause + Impact) In `PoolFactory::createPool` .symbol can be used instead of .name

```diff

-    string memory liquidityTokenSymbol = string.concat("ts", IERC20(tokenAddress).name());
+    string memory liquidityTokenSymbol = string.concat("ts", IERC20(tokenAddress).symbol());

```



[I-4] TITLE (Root Cause + Impact) `TSwapPool::Swap` indexed can be used in this event

```diff
-        IERC20 tokenIn,
+        IERC20 indexed tokenIn,
        uint256 amountTokenIn,
-        IERC20 tokenOut,
+        IERC20 indexed tokenOut,
```



[I-5] TITLE (Root Cause + Impact) In `TSwapPool::deposit` variable not used anywhere hence, can be removed

```diff
-    uint256 poolTokenReserves = i_poolToken.balanceOf(address(this));
```



[I-6] TITLE (Root Cause + Impact) In `TSwapPool::deposit` CEI not being followed

```diff
else {
+           liquidityTokensToMint = wethToDeposit;
            _addLiquidityMintAndTransfer(
                wethToDeposit,
                maximumPoolTokensToDeposit,
                wethToDeposit
            );
-            liquidityTokensToMint = wethToDeposit;
        }
```



[I-7] TITLE (Root Cause + Impact) In `TSwapPool::getInputAmountBasedOnOutput` constants should be used instead of magic numbers

```diff

+        uint256 public constant TOTAL_PERCENT = 10000;
+        uint256 public constant MARGIN = 997;
-        ((inputReserves * outputAmount) * 10000) /
-        ((outputReserves - outputAmount) * 997);
+        ((inputReserves * outputAmount) * TOTAL_PERCENT) /
+        ((outputReserves - outputAmount) * MARGIN);

```



[I-8] TITLE (Root Cause + Impact) `TSwapPool::swapExactInput` should be marked as `external` instead of public

```diff

function swapExactInput(
        IERC20 inputToken,uint256 inputAmount,IERC20 outputToken,uint256 minOutputAmount,uint64 deadline
    )
-        public
+        external

```



[I-9] TITLE (Root Cause + Impact)  `TSwapPool::totalLiquidityTokenSupply` can be marked as `external` instead of public

```diff

-    function totalLiquidityTokenSupply() public view returns (uint256) {
+    function totalLiquidityTokenSupply() external view returns (uint256) {

```



[I-10] TITLE (Root Cause + Impact) In `TSwapPool::getPriceOfOneWethInPoolTokens` constants should be used instead of magic numbers

```diff
uint256 public constant ONE_UNIT = 1e18;
-        1e18,
+        ONE_UNIT
        i_wethToken.balanceOf(address(this)),
```



[I-11] TITLE (Root Cause + Impact) In `TSwapPool::getPriceOfOnePoolTokenInWeth` constants should be used instead of magic numbers

```diff
uint256 public constant ONE_UNIT = 1e18;
-        1e18,
+        ONE_UNIT
        i_poolToken.balanceOf(address(this)),
```