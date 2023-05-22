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
import { ERC20System } from "./ERC20System.sol";
import { addressToBytes16} from "../utils.sol";

address constant SingletonKey = address(uint160(0x060D));

// Design problem: We want there to be different functionality for different tokens.
// Since a token's id is generated after the creation of this system (during contract deployment), there is no way to parse the tokenId beforehand.
// This system needs to be deployed alongside the proxy contract and the tokenId needs to be injected into the tokenId slot.
// This is a non-option because devs cant build their smart contracts in a js script lol 
// The other option is to predetermine the tokenId here and manually assign that id to the proxy contract, but this is also sub-ideal.
// The other option is to have a system that gatekeeps these systems to a certain tokenId, but that also doesn't make sense
// The other option is to deploy a separate

contract ERC20TestTokenMUD is ERC20System{

  constructor(IWorld world, address _tokenId, string memory _name, string memory _symbol) ERC20System(world, _tokenId, _name, _symbol) {
      bytes16 namespace = addressToBytes16(tokenId);

      // register this system
      bytes16 system = bytes16('ERC20System');

      world.registerFunctionSelector(namespace, system, "mint", "(address, uint256)");
      world.registerFunctionSelector(namespace, system, "burn", "(address, uint256)");
  }

  function mint(address to, uint256 amount) public override{
    _mint(to, amount);
  }

  function burn(address from, uint256 amount) public override{
    _burn(from, amount);
  }

}