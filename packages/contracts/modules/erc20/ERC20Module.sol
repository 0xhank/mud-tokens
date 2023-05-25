// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { IModule } from "@latticexyz/world/src/interfaces/IModule.sol";
import {ERC20Proxy} from "./internal/ERC20Proxy.sol";
import { WorldContext } from "@latticexyz/world/src/WorldContext.sol";

import { ERC20_MODULE_NAME, SYSTEM_NAME, TABLE_NAME } from "./constants.sol";

contract ERC20Module is IModule, WorldContext {

  function getName() public pure returns (bytes16) {
    return MODULE_NAME;
  }

  function install(bytes memory args) public {
    (string memory _name, string memory _type) = abi.decode(args, (string, string));
    IBaseWorld world = IBaseWorld(_world());

    ERC20Proxy proxy = new ERC20Proxy(world, _name, _type);
    // Register new tables 
    world.registerSystem(NAMESPACE, SYSTEM_NAME, snapSyncSystem, true);
    // Register system's functions
    world.registerFunctionSelector(NAMESPACE, SYSTEM_NAME, "getRecords", "(bytes32,uint256,uint256)");
    world.registerFunctionSelector(NAMESPACE, SYSTEM_NAME, "getNumKeysInTable", "(bytes32)");
      metadataTableId = world.registerTable(namespace,bytes16('metadata'), MetadataTable.getSchema(), MetadataTable.getKeySchema());
      balanceTableId = world.registerTable(namespace, bytes16('balance'), BalanceTable.getSchema(), BalanceTable.getKeySchema());
      allowanceTableId = world.registerTable(namespace, bytes16('allowance'), AllowanceTable.getSchema(), AllowanceTable.getKeySchema());
 
      MetadataTable.setName(metadataTableId, _name);
      MetadataTable.setSymbol(metadataTableId, _symbol);

      world.registerFunctionSelector(namespace, SYSTEM_NAME, "name", "()");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "symbol", "()");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "totalSupply", "()");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "balanceOf", "(address)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "transfer", "(address, uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "allowance", "(address, address)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "approve", "(address, uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "transferFrom", "(address, address, uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "increaseAllowance", "(address, uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "decreaseAllowance", "(address, uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "mintBypass", "(address, uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "burnBypass", "(address, uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "transferBypass", "(address, address, uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "approveBypass", "(address, address, uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "spendAllowanceBypass", "(address, address, uint256)");

  }
}
