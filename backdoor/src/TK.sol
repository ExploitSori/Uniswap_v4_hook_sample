// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
contract TK is ERC20{
    constructor() ERC20("TK", "TK"){
        
    }
    function mint(address target) external{
        _mint(target, 100 ether);
    }
}