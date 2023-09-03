// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { LibERC1155 } from "mudtokens/src/tokens.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { TokenLocation, TokenLocationData } from "../codegen/tables/TokenLocation.sol";
import { namespace, locationTableName as tableName } from "../constants.sol";

bytes16 constant systemName = bytes16("ERC1155Test.s");

contract ERC1155TestToken is System {
  function mint1155(uint256 tokenId, uint256 amount) public {
    LibERC1155._mint(namespace, _msgSender(), _msgSender(), tokenId, amount, "");
  }

  function burn1155(uint256 tokenId, uint256 amount) public {
    LibERC1155._burn(namespace, _msgSender(), _msgSender(), tokenId, amount);
  }

  function transfer1155(
    address to,
    uint256 tokenId,
    uint256 amount
  ) public {
    LibERC1155._safeTransferFrom(namespace, _msgSender(), _msgSender(), to, tokenId, amount, "");
  }

  function place1155(
    uint256 tokenId,
    uint256 x,
    uint256 y
  ) public {
    uint256 balance = LibERC1155.balanceOf(namespace, _msgSender(), tokenId);
    require(balance > 0, "you dont have this token or its fungible");
    TokenLocation.set(tokenId, x, y);
  }

  function location1155(uint256 tokenId) public view returns (uint256 x, uint256 y) {
    TokenLocationData memory locationData = TokenLocation.get(tokenId);
    return (locationData.x, locationData.y);
  }
}
