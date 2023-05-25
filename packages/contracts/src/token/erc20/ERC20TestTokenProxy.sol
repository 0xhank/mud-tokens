// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20Proxy.sol";
import { IWorld } from "../../codegen/world/IWorld.sol";
import {ERC20TestSystem } from "./ERC20TestSystem.sol";

contract ERC20TestTokenProxy is ERC20Proxy {

  ERC20TestSystem immutable token;
  constructor(IWorld world, ERC20TestSystem _token, string memory _name) ERC20Proxy(world, _token, _name ) 
  {
      token = _token;
  }
    function mint(address to, uint256 amount) public virtual {
        _mint(to,amount);
    }

    function burn(address from, uint amount) public virtual {
        _burn(from, amount);
    }
}