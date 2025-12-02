[S-#] TITLE (Root Cause + Impact)

Description:

Impact:

Proof of Concept:

Recommended Mitigation:






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