// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20MUD.sol";
import { IWorld } from "../codegen/world/IWorld.sol";

contract ERC20TestTokenProxy is ERC20MUD {

  constructor(IWorld worldAddress, string memory _name, string memory _symbol) ERC20MUD (worldAddress, _name, _symbol)
  {
  }

    function mint(address to, uint256 amount) public virtual {
        _mint(to,amount);
    }

    function burn(address from, uint amount) public virtual {
        _burn(from, amount);
    }
}