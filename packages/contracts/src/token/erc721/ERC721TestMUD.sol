// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {ERC721System} from "./ERC721System.sol";
import { IWorld } from "../../codegen/world/IWorld.sol";
import {nameToBytes16} from "../../utils.sol";

contract ERC721TestMUD is ERC721System {

    bytes16 private immutable namespace;
    constructor(IWorld world, address proxy, string memory name, string memory symbol) ERC721System(world, proxy, name, symbol) {
      namespace = nameToBytes16(name);
    }
    
    function safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }

    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _burn(tokenId);
    }   
}