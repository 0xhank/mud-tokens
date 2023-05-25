// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { IModule } from "@latticexyz/world/src/interfaces/IModule.sol";

import { WorldContext } from "@latticexyz/world/src/WorldContext.sol";

import { SnapSyncSystem } from "./SnapSyncSystem.sol";

import { NAMESPACE, MODULE_NAME, SYSTEM_NAME, TABLE_NAME } from "./constants.sol";

contract SnapSyncModule is IModule, WorldContext {
  // Since the SnapSyncSystem only exists once per World and writes to
  // known tables, we can deploy it once and register it in multiple Worlds.

  function getName() public pure returns (bytes16) {
    return MODULE_NAME;
  }

  function install(bytes memory) public {
    IBaseWorld world = IBaseWorld(_world());

    ERC20Proxy proxy = new ERC20Proxy();
    // Register system
    world.registerSystem(NAMESPACE, SYSTEM_NAME, snapSyncSystem, true);
    // Register system's functions
    world.registerFunctionSelector(NAMESPACE, SYSTEM_NAME, "getRecords", "(bytes32,uint256,uint256)");
    world.registerFunctionSelector(NAMESPACE, SYSTEM_NAME, "getNumKeysInTable", "(bytes32)");
  }
}
