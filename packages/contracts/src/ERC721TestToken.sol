// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {System} from "@latticexyz/world/src/System.sol";
import {LibERC721} from "../tokens/erc721/LibERC721.sol";
import {ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import {TokenLocation, TokenLocationData } from "./codegen/tables/TokenLocation.sol";


bytes16 constant namespace = bytes16("ERC721Test");
bytes16 constant systemName = bytes16("ERC721Test.s");
// TODO: This should autogenerate in the table
bytes16 constant tableName = bytes16("ERC721Test.t");

contract ERC721TestToken is System {
  function mint(uint256 tokenId) public {
    LibERC721._safeMint(_msgSender(), namespace, _msgSender(), tokenId);
  }

  function burn(uint256 tokenId) public {
    LibERC721._burn(namespace, tokenId);
  }

  function transfer(address to, uint256 tokenId) public {
    address owner = LibERC721.ownerOf(namespace, tokenId);
    require(owner == _msgSender(), "ERC721TestToken: not owner of token");
    LibERC721._transfer(namespace, owner, to, tokenId);
  }

  function place(uint256 tokenId, uint256 x, uint256 y) public {
    address owner = LibERC721.ownerOf(namespace, tokenId);
    require(owner == _msgSender(), "ERC721TestToken: not owner of token");
    TokenLocation.set(ResourceSelector.from(namespace, tableName), tokenId, x, y);
  }

  function location(uint256 tokenId) public view returns (uint256 x, uint256 y){
    TokenLocationData memory locationData = TokenLocation.get(ResourceSelector.from(namespace, tableName), tokenId);
    return (locationData.x, locationData.y);
  }
}
