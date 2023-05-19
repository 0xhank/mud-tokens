// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../src/proxy/ERC20MUD.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { console } from "forge-std/console.sol";

contract ERC20TestToken is ERC20MUD {

  constructor(address worldAddress, string memory _name, string memory _symbol) ERC20MUD (worldAddress, _name, _symbol)
  {
  }
    function mint(address to, uint256 amount) public virtual {
        _mint(to,amount);
    }

    function burn(address from, uint amount) public virtual {
        _burn(from, amount);
    }
}