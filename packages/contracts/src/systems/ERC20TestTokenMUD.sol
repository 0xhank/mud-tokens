// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { ERC20Table } from "../codegen/Tables.sol";
import { AllowanceTable } from "../codegen/Tables.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { IERC20MUD } from "../proxy/interfaces/IERC20MUD.sol"; 
import { ERC20MUD } from "../proxy/ERC20MUD.sol"; 
import { console } from "forge-std/console.sol";
import { ERC20System, SYSTEM_NAME } from "./ERC20System.sol";
import { addressToBytes16} from "../utils.sol";

address constant SingletonKey = address(uint160(0x060D));

contract ERC20TestTokenMUD is ERC20System{

  constructor(IWorld world, address _tokenId, string memory _name, string memory _symbol) ERC20System(world, _tokenId, _name, _symbol) {
      bytes16 namespace = addressToBytes16(tokenId);

      world.registerFunctionSelector(namespace, SYSTEM_NAME, "mint", "(address, uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "burn", "(address, uint256)");
  }

  function mint(address to, uint256 amount) public{
    _mint(to, amount);
  }

  function burn(address from, uint256 amount) public {
    _burn(from, amount);
  }

}