// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { LibERC20 } from "@latticexyz/world/src/modules/tokens/erc20/LibERC20.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { TokenLocation, TokenLocationData } from "../codegen/tables/TokenLocation.sol";
import { namespace, locationTableName as tableName } from "../constants.sol";

bytes16 constant systemName = bytes16("ERC20Test.s");

// TODO: This should autogenerate in the table

contract ERC20TestToken is System {
  function mint20(uint256 amount) public {
    LibERC20._mint(namespace,  _msgSender(), amount);
  }

  function burn20(uint256 amount) public {
    LibERC20._burn(namespace, _msgSender(), amount);
  }

  function transfer20(address to, uint256 amount) public {
    uint256 stored = LibERC20.balanceOf(namespace, _msgSender());
    require(stored >= amount, "ERC20TestToken: not enough tokens");
    LibERC20._transfer(namespace, _msgSender(), to, amount);
  }

  function place20(
    uint256 amount,
    uint256 x,
    uint256 y
  ) public {
    uint256 balance = LibERC20.balanceOf(namespace, _msgSender());
    require(balance >=  amount, "ERC20TestToken: not owner of token");
    TokenLocation.set(amount, x, y);
  }

  function location20(uint256 amount) public view returns (uint256 x, uint256 y) {
    TokenLocationData memory locationData = TokenLocation.get(amount);
    return (locationData.x, locationData.y);
  }
}
