// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import { IWorld } from "../../codegen/world/IWorld.sol";
import { ERC20System, SYSTEM_NAME } from "./ERC20System.sol";
import {nameToBytes16} from "../../utils.sol";

contract ERC20TestSystem is ERC20System{

  constructor(string memory _name, string memory _symbol) ERC20System(_name, _symbol) {

  }

  function mint(address to, uint256 amount) public{
    _mint(to, amount);
  }

  function burn(address from, uint256 amount) public {
    _burn(from, amount);
  }
}