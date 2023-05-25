// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import { ERC20System } from "../src/modules/erc20/ERC20System.sol";
import {nameToBytes16} from "./modules/common/utils.sol";

contract ERC20TestSystem is ERC20System{

  constructor() ERC20System("ERC20Test") {}

  function mint(address to, uint256 amount) public{
    _mint(to, amount);
  }

  function burn(address from, uint256 amount) public {
    _burn(from, amount);
  }
}