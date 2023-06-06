// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ERC721System } from "@latticexyz/world/src/modules/tokens/erc721/ERC721System.sol";
import {TokenLocation, TokenLocationData } from "./codegen/tables/TokenLocation.sol";

bytes16 constant namespace = bytes16("ERC721Test");

// TODO: This should autogenerate in the table
bytes16 constant tableName = bytes16("ERC721Test.t");

contract ERC721TestToken is ERC721System {
  function mint(uint256 tokenId) public {
    _safeMint(namespace, _msgSender(), tokenId);
  }

  function burn(uint256 tokenId) public {
    _burn(namespace, tokenId);
  }

  function transfer(address to, uint256 tokenId) public {
    address owner = ownerOf(namespace, tokenId);
    require(owner == _msgSender(), "ERC721TestToken: not owner of token");
    _transfer(namespace, owner, to, tokenId);
  }

  function place(uint256 tokenId, uint256 x, uint256 y) public {
    address owner = ownerOf(namespace, tokenId);
    require(owner == _msgSender(), "ERC721TestToken: not owner of token");
    TokenLocation.set(from(namespace, tableName), tokenId, x, y);
  }

  function location(uint256 tokenId) public view returns (uint256 x, uint256 y){
    TokenLocationData memory locationData = TokenLocation.get(from(namespace, tableName), tokenId);
    return (locationData.x, locationData.y);
  }
}
