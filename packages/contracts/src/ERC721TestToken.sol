// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ERC721System } from "@latticexyz/world/src/modules/tokens/erc721/ERC721System.sol";

bytes16 constant namespace = bytes16('ERC721');
bytes16 constant tableName = bytes16('ERC721.t');

contract ERC721TestToken is ERC721System {
  function mint(address to, uint256 tokenId) public{
    _mint(namespace, to, tokenId);
  }

  function burn(uint256 tokenId) public {
    _burn(namespace, tokenId);
  }
  
  function transfer(address to, uint256 tokenId) public {
    address owner = ownerOf(namespace, tokenId);
    _transfer(namespace, owner, to, tokenId);
  }
}
