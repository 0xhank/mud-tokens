// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IBaseWorld } from "../../../interfaces/IBaseWorld.sol";
import { IModule } from "../../../interfaces/IModule.sol";
import {ERC20Proxy} from "./ERC20Proxy.sol";
import { WorldContext } from "../../../WorldContext.sol";

import { MODULE_NAME, ERC20_SYSTEM_NAME, METADATA_TABLE_NAME, BALANCE_TABLE_NAME, ALLOWANCE_TABLE_NAME } from "../common/constants.sol";
import {nameToBytes16} from "../common/utils.sol";
import { BalanceTable } from "../common/BalanceTable.sol";
import { AllowanceTable} from "../common/AllowanceTable.sol";
import { MetadataTable } from "../common/MetadataTable.sol";
import {ERC20System} from "./ERC20System.sol";

contract ERC20TestSystem is ERC20System {

  constructor() ERC20System("ERC20Test") {}

  function mint(address to, uint256 amount) public{
    _mint(to, amount);
  }

  function burn(address from, uint256 amount) public {
    _burn(from, amount);
  }
}

contract ERC20Module is IModule, WorldContext {

  ERC20TestSystem private token = new ERC20TestSystem();

  function getName() public pure returns (bytes16) {
    return MODULE_NAME;
  }

  function install(bytes memory args) public {
    (string memory _name, string memory _symbol ) = abi.decode(args, (string, string));
    IBaseWorld world = IBaseWorld(_world());
    ERC20Proxy proxy = new ERC20Proxy(world, _name);
    bytes16 NAMESPACE = nameToBytes16(_name);
    world.registerTable(NAMESPACE, BALANCE_TABLE_NAME, BalanceTable.getSchema(), BalanceTable.getKeySchema());
    bytes32 metadataTableId = world.registerTable(NAMESPACE, METADATA_TABLE_NAME, MetadataTable.getSchema(), MetadataTable.getKeySchema());
    world.registerTable(NAMESPACE, ALLOWANCE_TABLE_NAME, AllowanceTable.getSchema(), AllowanceTable.getKeySchema());
    world.grantAccess(NAMESPACE, METADATA_TABLE_NAME, address(proxy));
    world.grantAccess(NAMESPACE, ALLOWANCE_TABLE_NAME, address(proxy));
    world.grantAccess(NAMESPACE, BALANCE_TABLE_NAME, address(proxy));
    MetadataTable.setName(world, metadataTableId, _name);
    MetadataTable.setSymbol(world, metadataTableId, _symbol);
    MetadataTable.setProxy(world, metadataTableId, address(proxy));

    // todo: remove this once inheritance and custom namespaces are added to MUD
    world.registerSystem(NAMESPACE, ERC20_SYSTEM_NAME, token, true);
    world.registerFunctionSelector(NAMESPACE, ERC20_SYSTEM_NAME, "mint", "(address, uint256)");
    world.registerFunctionSelector(NAMESPACE, ERC20_SYSTEM_NAME, "burn", "(address, uint256)");
    world.registerFunctionSelector(NAMESPACE, ERC20_SYSTEM_NAME, "name", "()");
    world.registerFunctionSelector(NAMESPACE, ERC20_SYSTEM_NAME, "symbol", "()");
    world.registerFunctionSelector(NAMESPACE, ERC20_SYSTEM_NAME, "proxy", "()");
    world.registerFunctionSelector(NAMESPACE, ERC20_SYSTEM_NAME, "totalSupply", "()");
    world.registerFunctionSelector(NAMESPACE, ERC20_SYSTEM_NAME, "balanceOf", "(address)");
    world.registerFunctionSelector(NAMESPACE, ERC20_SYSTEM_NAME, "transfer", "(address, uint256)");
    world.registerFunctionSelector(NAMESPACE, ERC20_SYSTEM_NAME, "allowance", "(address, address)");
    world.registerFunctionSelector(NAMESPACE, ERC20_SYSTEM_NAME, "approve", "(address, uint256)");
    world.registerFunctionSelector(NAMESPACE, ERC20_SYSTEM_NAME, "transferFrom", "(address, address, uint256)");
    world.registerFunctionSelector(NAMESPACE, ERC20_SYSTEM_NAME, "increaseAllowance", "(address, uint256)");
    world.registerFunctionSelector(NAMESPACE, ERC20_SYSTEM_NAME, "decreaseAllowance", "(address, uint256)");
    world.registerFunctionSelector(NAMESPACE, ERC20_SYSTEM_NAME, "mintBypass", "(address, uint256)");
    world.registerFunctionSelector(NAMESPACE, ERC20_SYSTEM_NAME, "burnBypass", "(address, uint256)");
    world.registerFunctionSelector(NAMESPACE, ERC20_SYSTEM_NAME, "transferBypass", "(address, address, uint256)");
    world.registerFunctionSelector(NAMESPACE, ERC20_SYSTEM_NAME, "approveBypass", "(address, address, uint256)");
    world.registerFunctionSelector(NAMESPACE, ERC20_SYSTEM_NAME, "spendAllowanceBypass", "(address, address, uint256)");
  }
}
