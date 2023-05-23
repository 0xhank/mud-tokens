// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20Proxy.sol";
import { IWorld } from "../../codegen/world/IWorld.sol";
import {ERC20TestTokenMUD } from "./ERC20TestTokenMUD.sol";

contract ERC20TestTokenProxy is ERC20Proxy {
  constructor(IWorld world, string memory _name, string memory _symbol) 
  {
    ERC20TestTokenMUD token = new ERC20TestTokenMUD(world, address(this), _name, _symbol);
    setup(world, token, _name);
  }
    function mint(address to, uint256 amount) public virtual {
        _mint(to,amount);
    }

    function burn(address from, uint amount) public virtual {
        _burn(from, amount);
    }
}