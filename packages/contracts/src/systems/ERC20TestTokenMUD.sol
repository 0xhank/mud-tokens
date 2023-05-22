// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import { IWorld } from "../codegen/world/IWorld.sol";
import { ERC20System, SYSTEM_NAME } from "./ERC20System.sol";
import { addressToBytes16} from "../utils.sol";

contract ERC20TestTokenMUD is ERC20System{

  bytes16 immutable namespace;
  constructor(IWorld world, address _tokenId, string memory _name, string memory _symbol) ERC20System(world, _tokenId, _name, _symbol) {
      namespace = addressToBytes16(tokenId);
  }

  function mint(address to, uint256 amount) public{
    _mint(to, amount);
    world.registerFunctionSelector(namespace, SYSTEM_NAME, "mint", "(address, uint256)");
  }

  function burn(address from, uint256 amount) public {
    world.registerFunctionSelector(namespace, SYSTEM_NAME, "burn", "(address, uint256)");
    _burn(from, amount);
  }
}