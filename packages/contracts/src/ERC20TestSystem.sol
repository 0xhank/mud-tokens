// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ERC20System } from "@latticexyz/world/src/modules/tokens/erc20/ERC20System.sol";

contract ERC20TestSystem is ERC20System {

  constructor() ERC20System("ERC20Test") {}

  function mint(address to, uint256 amount) public{
    _mint(to, amount);
  }

  function burn(address from, uint256 amount) public {
    _burn(from, amount);
  }
}
