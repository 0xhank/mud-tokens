// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../src/proxy/ERC20MUD.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";

contract SampleToken is ERC20MUD {

  constructor(address worldAddress, address holder, uint256 totalSupply) ERC20MUD (worldAddress, "Sample", "SAM")
  {
    _mint(holder, totalSupply);
  }
}