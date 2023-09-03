// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { ResourceSelector, ROOT_NAMESPACE } from "@latticexyz/world/src/ResourceSelector.sol";

import { ERC20Proxy } from "./ERC20Proxy.sol";
import { AllowanceTable } from "../common/AllowanceTable.sol";
import { BalanceTable } from "../common/BalanceTable.sol";
import { MetadataTable } from "../common/MetadataTable.sol";

import { ERC20_ALLOWANCE_T as ALLOWANCE, ERC20_BALANCE_T as BALANCE, ERC20_METADATA_T as METADATA } from "../common/constants.sol";

library ERC20Registration {
  function install(IBaseWorld world, bytes16 namespace, string memory _name, string memory symbol) internal {
    ERC20Proxy proxy = new ERC20Proxy(world, namespace);

    bytes32 metadataTableId = registerTables(world, namespace);

    address proxyAddress = address(proxy);

    // set token metadata
    MetadataTable.setProxy(world, metadataTableId, proxyAddress);
    MetadataTable.setName(world, metadataTableId, _name);
    MetadataTable.setSymbol(world, metadataTableId, symbol);

    // let the proxy contract modify tables directly
    world.grantAccess(namespace, ALLOWANCE, proxyAddress);
    world.grantAccess(namespace, BALANCE, proxyAddress);
    world.grantAccess(namespace, METADATA, proxyAddress);
  }

  function install(IBaseWorld world, string memory _name, string memory symbol) internal {
    install(world, ROOT_NAMESPACE, _name, symbol);
  }

  function registerTables(IBaseWorld world, bytes16 namespace) private returns (bytes32 tableId) {
    tableId = ResourceSelector.from(namespace, ALLOWANCE);
    AllowanceTable.registerSchema(world, tableId);
    AllowanceTable.setMetadata(world, tableId);

    tableId = ResourceSelector.from(namespace, BALANCE);
    BalanceTable.registerSchema(world, tableId);
    BalanceTable.setMetadata(world, tableId);

    tableId = ResourceSelector.from(namespace, METADATA);
    MetadataTable.registerSchema(world, tableId);
    MetadataTable.setMetadata(world, tableId);
  }
}
