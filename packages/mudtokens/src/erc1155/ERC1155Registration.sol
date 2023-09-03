// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { ERC1155Proxy } from "./ERC1155Proxy.sol";
import { ERC1155ApprovalTable as Approvals } from "./ERC1155ApprovalTable.sol";
import { ERC1155MetadataTable as Metadata } from "./ERC1155MetadataTable.sol";
import { ERC1155BalanceTable as Balance } from "./ERC1155BalanceTable.sol";
import { ResourceSelector, ROOT_NAMESPACE } from "@latticexyz/world/src/ResourceSelector.sol";

import { ERC1155_APPROVAL_T as APPROVALS, ERC1155_BALANCE_T as BALANCE, ERC1155_METADATA_T as METADATA } from "../common/constants.sol";

library ERC1155Registration {
  function install(IBaseWorld world, bytes16 namespace, string memory uri) internal {
    ERC1155Proxy proxy = new ERC1155Proxy(world, namespace);

    bytes32 metadataTableId = registerTables(world, namespace);

    address proxyAddress = address(proxy);

    // set token metadata
    Metadata.setProxy(world, metadataTableId, proxyAddress);
    Metadata.setUri(world, metadataTableId, uri);

    // let the proxy contract modify tables directly
    world.grantAccess(namespace, APPROVALS, proxyAddress);
    world.grantAccess(namespace, BALANCE, proxyAddress);
    world.grantAccess(namespace, METADATA, proxyAddress);
  }

  function install(IBaseWorld world, string memory uri) internal {
    ERC1155Proxy proxy = new ERC1155Proxy(world, ROOT_NAMESPACE);

    bytes32 metadataTableId = registerTables(world, ROOT_NAMESPACE);

    address proxyAddress = address(proxy);

    // set token metadata
    Metadata.setProxy(world, metadataTableId, proxyAddress);
    Metadata.setUri(world, metadataTableId, uri);

    // let the proxy contract modify tables directly
    world.grantAccess(ROOT_NAMESPACE, APPROVALS, proxyAddress);
    world.grantAccess(ROOT_NAMESPACE, BALANCE, proxyAddress);
    world.grantAccess(ROOT_NAMESPACE, METADATA, proxyAddress);
  }

  function registerTables(IBaseWorld world, bytes16 namespace) private returns (bytes32 tableId) {
    tableId = ResourceSelector.from(namespace, APPROVALS);
    Approvals.registerSchema(world, tableId);
    Approvals.setMetadata(world, tableId);

    tableId = ResourceSelector.from(namespace, BALANCE);
    Balance.registerSchema(world, tableId);
    Balance.setMetadata(world, tableId);

    tableId = ResourceSelector.from(namespace, METADATA);
    Metadata.registerSchema(world, tableId);
    Metadata.setMetadata(world, tableId);
  }
}
