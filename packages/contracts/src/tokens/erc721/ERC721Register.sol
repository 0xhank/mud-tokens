// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import {ERC721Proxy} from "./ERC721Proxy.sol";

import {ERC721_SYSTEM_NAME, ERC721_TABLE_NAME, METADATA_TABLE_NAME, BALANCE_TABLE_NAME, ALLOWANCE_TABLE_NAME } from "../common/constants.sol";
import { nameToBytes16} from "../common/utils.sol";
import { BalanceTable } from "../common/BalanceTable.sol";
import { AllowanceTable} from "../common/AllowanceTable.sol";
import { MetadataTable } from "../common/MetadataTable.sol";
import { ERC721Table } from "./ERC721Table.sol";
import {ERC721System} from "./ERC721System.sol";
import {ResourceSelector} from "@latticexyz/world/src/ResourceSelector.sol";

contract ERC721Register {
  function install(IBaseWorld world, string memory _name, string memory _symbol, ERC721System token) public {
    bytes16 namespace = nameToBytes16(_name);

    // namespace is derived from the smart object's name
    world.registerSystem(namespace, ERC721_SYSTEM_NAME, token, true);

    ERC721Proxy proxy = new ERC721Proxy(world, _name);
    // NOTE: Once inheritance and custom namespace is implemented in MUD, this code will be automatically executed in the MUD deploy script
    // Register core ERC721 Systems to world
    registerCoreFunctions(world, namespace);
    bytes32 metadataTableId = registerTables(world, namespace);
    address proxyAddress = address(proxy);
    // set token metadata 
    MetadataTable.setProxy(world, metadataTableId, proxyAddress);
    MetadataTable.setName(world, metadataTableId, _name);
    MetadataTable.setSymbol(world, metadataTableId, _symbol);

    // let the proxy contract modify tables directly
    world.grantAccess(namespace, METADATA_TABLE_NAME, proxyAddress);
    world.grantAccess(namespace, ALLOWANCE_TABLE_NAME, proxyAddress);
    world.grantAccess(namespace, BALANCE_TABLE_NAME, proxyAddress);
    world.grantAccess(namespace, ERC721_TABLE_NAME, proxyAddress);
  }
 
  function registerCoreFunctions(IBaseWorld world, bytes16 namespace) private { 
    world.registerFunctionSelector(namespace, ERC721_SYSTEM_NAME, "name", "()");
    world.registerFunctionSelector(namespace, ERC721_SYSTEM_NAME, "symbol", "()");
    world.registerFunctionSelector(namespace, ERC721_SYSTEM_NAME, "proxy", "()");
    world.registerFunctionSelector(namespace, ERC721_SYSTEM_NAME, "totalSupply", "()");
    world.registerFunctionSelector(namespace, ERC721_SYSTEM_NAME, "balanceOf", "(address)");
    world.registerFunctionSelector(namespace, ERC721_SYSTEM_NAME, "transfer", "(address, uint256)");
    world.registerFunctionSelector(namespace, ERC721_SYSTEM_NAME, "allowance", "(address, address)");
    world.registerFunctionSelector(namespace, ERC721_SYSTEM_NAME, "approve", "(address, uint256)");
    world.registerFunctionSelector(namespace, ERC721_SYSTEM_NAME, "transferFrom", "(address, address, uint256)");
    world.registerFunctionSelector(namespace, ERC721_SYSTEM_NAME, "increaseAllowance", "(address, uint256)");
    world.registerFunctionSelector(namespace, ERC721_SYSTEM_NAME, "decreaseAllowance", "(address, uint256)");
  }

  function registerTables(IBaseWorld world, bytes16 namespace) private returns (bytes32 metadataTableId){
    world.registerTable(namespace, BALANCE_TABLE_NAME, BalanceTable.getSchema(), BalanceTable.getKeySchema());
    world.registerTable(namespace, ALLOWANCE_TABLE_NAME, AllowanceTable.getSchema(), AllowanceTable.getKeySchema());
    world.registerTable(namespace, ERC721_TABLE_NAME, ERC721Table.getSchema(), ERC721Table.getKeySchema());
    metadataTableId = world.registerTable(namespace, METADATA_TABLE_NAME, MetadataTable.getSchema(), MetadataTable.getKeySchema());
  }
}
