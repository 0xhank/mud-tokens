// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721Proxy} from "./ERC721Proxy.sol";
import {ERC721TestMUD } from "./ERC721TestMUD.sol";
import { IWorld } from "../../codegen/world/IWorld.sol";
import { console } from "forge-std/console.sol";

contract ERC721TestProxy is ERC721Proxy {

    constructor(IWorld world, string memory name, string memory symbol) {
      ERC721TestMUD token = new ERC721TestMUD(world, address(this), name, symbol);
      setup(world, token, name);
    }
    
    function safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }

    function mint (address to, uint256 tokenId) public {
      console.log('to: ', to);
      console.log('tokenId: ', tokenId);
      _mint(to, tokenId);
    }

    function mint(address to, uint256 tokenId, string memory _tokenURI) public {
      _mint(to, tokenId);
      _setTokenURI(tokenId, _tokenURI);
    }

    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: caller is not token owner or approved");
        _burn(tokenId);
    }
}