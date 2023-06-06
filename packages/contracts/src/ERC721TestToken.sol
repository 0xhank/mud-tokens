// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ERC721System } from "@latticexyz/world/src/modules/tokens/erc721/ERC721System.sol";

bytes16 constant namespace = bytes16("ERC721");
bytes16 constant tableName = bytes16("ERC721.t");

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
}
