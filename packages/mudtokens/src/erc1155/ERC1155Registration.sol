// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { ERC1155Proxy } from "./ERC1155Proxy.sol";
import {ERC1155ApprovalTable as Approvals, ERC1155BalanceTable as Balance, ERC1155MetadataTable as Metadata} from "../codegen/Tables.sol";
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
    world.grantAccess(ResourceSelector.from(namespace, APPROVALS), proxyAddress);
    world.grantAccess(ResourceSelector.from(namespace, BALANCE), proxyAddress);
    world.grantAccess(ResourceSelector.from(namespace, METADATA), proxyAddress);
  }

  function install(IBaseWorld world, string memory uri) internal {
    install(world, ROOT_NAMESPACE, uri);
  }

  function registerTables(IBaseWorld world, bytes16 namespace) private returns (bytes32 tableId) {
    tableId = ResourceSelector.from(namespace, APPROVALS);
    Approvals.register(world, tableId);

    tableId = ResourceSelector.from(namespace, BALANCE);
    Balance.register(world, tableId);

    tableId = ResourceSelector.from(namespace, METADATA);
    Metadata.register(world, tableId);
  }
}
