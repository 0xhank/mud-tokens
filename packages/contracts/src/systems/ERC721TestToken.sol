// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { LibERC721 } from "@latticexyz/world/src/modules/tokens/erc721/LibERC721.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { TokenLocation, TokenLocationData } from "../codegen/tables/TokenLocation.sol";
import { namespace, locationTableName as tableName } from "../constants.sol";

bytes16 constant systemName = bytes16("ERC721Test.s");

// TODO: This should autogenerate in the table

contract ERC721TestToken is System {
  function mint721(uint256 tokenId) public {
    LibERC721._safeMint(namespace, _msgSender(), _msgSender(), tokenId);
  }

  function burn721(uint256 tokenId) public {
    LibERC721._burn(namespace, tokenId);
  }

  function transfer721(address to, uint256 tokenId) public {
    address owner = LibERC721.ownerOf(namespace, tokenId);
    require(owner == _msgSender(), "ERC721TestToken: not owner of token");
    LibERC721._transfer(namespace, owner, to, tokenId);
  }

  function place721(
    uint256 tokenId,
    uint256 x,
    uint256 y
  ) public {
    address owner = LibERC721.ownerOf(namespace, tokenId);
    require(owner == _msgSender(), "ERC721TestToken: not owner of token");
    TokenLocation.set(tokenId, x, y);
  }

  function location721(uint256 tokenId) public view returns (uint256 x, uint256 y) {
    TokenLocationData memory locationData = TokenLocation.get(tokenId);
    return (locationData.x, locationData.y);
  }
}
