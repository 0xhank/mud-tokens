// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { ERC721Proxy } from "./ERC721Proxy.sol";

import { ERC721_T, ERC721_METADATA_T as METADATA_T, ERC721_BALANCE_T as BALANCE_T, ERC721_ALLOWANCE_T as ALLOWANCE_T } from "../common/constants.sol";
import { BalanceTable } from "../common/BalanceTable.sol";
import { AllowanceTable } from "../common/AllowanceTable.sol";
import { MetadataTable } from "../common/MetadataTable.sol";
import { ERC721Table } from "./ERC721Table.sol";
import { ResourceSelector, ROOT_NAMESPACE } from "@latticexyz/world/src/ResourceSelector.sol";

library ERC721Registration {
  function install(IBaseWorld world, bytes16 namespace, string memory _name, string memory _symbol) internal {
    ERC721Proxy proxy = new ERC721Proxy(world, namespace);

    bytes32 metadataTableId = registerTables(world, namespace);

    address proxyAddress = address(proxy);

    // set token metadata
    MetadataTable.setProxy(world, metadataTableId, proxyAddress);
    MetadataTable.setName(world, metadataTableId, _name);
    MetadataTable.setSymbol(world, metadataTableId, _symbol);

    proxyAddress = MetadataTable.getProxy(world, metadataTableId);

    // let the proxy contract modify tables directly
    world.grantAccess(namespace, METADATA_T, proxyAddress);
    world.grantAccess(namespace, ALLOWANCE_T, proxyAddress);
    world.grantAccess(namespace, BALANCE_T, proxyAddress);
    world.grantAccess(namespace, ERC721_T, proxyAddress);
  }

  function install(IBaseWorld world, string memory _name, string memory _symbol) internal {
    install(world, ROOT_NAMESPACE, _name, _symbol);
  }

  function registerTables(IBaseWorld world, bytes16 namespace) private returns (bytes32 tableId) {
    tableId = ResourceSelector.from(namespace, BALANCE_T);
    BalanceTable.registerSchema(world, tableId);
    BalanceTable.setMetadata(world, tableId);

    tableId = ResourceSelector.from(namespace, ALLOWANCE_T);
    AllowanceTable.registerSchema(world, tableId);
    AllowanceTable.setMetadata(world, tableId);

    tableId = ResourceSelector.from(namespace, ERC721_T);
    ERC721Table.registerSchema(world, tableId);
    ERC721Table.setMetadata(world, tableId);

    tableId = ResourceSelector.from(namespace, METADATA_T);
    MetadataTable.registerSchema(world, tableId);
    MetadataTable.setMetadata(world, tableId);
  }
}
