// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "../../codegen/world/IWorld.sol";
import { AllowanceTable } from "../../codegen/Tables.sol";
import { MetadataTable } from "../../codegen/Tables.sol";
import { BalanceTable } from "../../codegen/Tables.sol";
import { ERC20Proxy } from "./ERC20Proxy.sol"; 
import {nameToBytes16, tokenToTable, Token} from "../../utils.sol";

bytes16 constant SYSTEM_NAME = bytes16('erc20_system');

contract ERC20System is System {

    IWorld immutable world;
    address proxy;
    bytes32 immutable metadataTableId;
    bytes32 immutable balanceTableId;
    bytes32 immutable allowanceTableId;
    constructor(IWorld _world, address _proxy, string memory _name, string memory _symbol) {
      world = _world;
      proxy = _proxy;
      bytes16 namespace = nameToBytes16(_name);
      // register this system
      world.registerSystem(namespace, SYSTEM_NAME, this, true);
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
      // register tables
      metadataTableId = world.registerTable(namespace,bytes16('metadata'), MetadataTable.getSchema(), MetadataTable.getKeySchema());
      balanceTableId = world.registerTable(namespace, bytes16('balance'), BalanceTable.getSchema(), BalanceTable.getKeySchema());
      allowanceTableId = world.registerTable(namespace, bytes16('allowance'), AllowanceTable.getSchema(), AllowanceTable.getKeySchema());

      // metadataTableId = tokenToTable('metadata', Token.ERC20);
      // balanceTableId = tokenToTable('balance', Token.ERC20);
      // allowanceTableId =tokenToTable('allowance', Token.ERC20);
 
      MetadataTable.setName(world, metadataTableId, _name);
      MetadataTable.setSymbol(world, metadataTableId, _symbol);
      MetadataTable.setProxy(world, metadataTableId, proxy);
    }

    function name() public view virtual returns (string memory) {
        return MetadataTable.getName(world, metadataTableId);
    }

    function symbol() public view virtual returns (string memory) {
        return MetadataTable.getSymbol(world, metadataTableId);
    }
  
    function totalSupply() public view  virtual returns (uint256) {
        return MetadataTable.getTotalSupply(world, metadataTableId);
    }

    function balanceOf(address account) public view  virtual returns (uint256) {
        return BalanceTable.get(world, balanceTableId, account);
    }

    function transfer(address to, uint256 amount) public virtual{
        address owner = _msgSender();
        _transfer(owner, to, amount);
    }

    function allowance(address owner, address spender) public virtual view returns (uint256) {
        return AllowanceTable.get(world, allowanceTableId, owner, spender);
    }
    
    function approve(address spender, uint256 amount) public virtual {
        address owner = _msgSender();
        _approve(owner, spender, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public virtual {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) virtual public {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(owner, spender, currentAllowance - subtractedValue);
    }

    
    /***** 
      The next five functions are only accessible via a direct call from the proxy contract
     */

    function transferBypass(address from, address to, uint256 amount) virtual public {
      require(_msgSender() == proxy, "ERC20System: not authorized to transfer");
      _transfer(from, to, amount);
    }
    function mintBypass(address account, uint256 amount) virtual public {
      require(_msgSender() == proxy, "ERC20System: not authorized to mint");
      _mint(account, amount);
    }

    function burnBypass(address account, uint256 amount) virtual public {
      require(_msgSender() == proxy, "ERC20System: not authorized to burn");
      _burn(account, amount);
    } 

    function approveBypass(address owner, address spender, uint256 amount) public {
      require(_msgSender() == proxy, "ERC20System: not authorized to approve");
      _approve(owner, spender, amount);
    }

    function spendAllowanceBypass(address owner, address spender, uint256 amount) public {
      require(_msgSender() == proxy, "ERC20System: not authorized to spend allowance");
      _spendAllowance(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = BalanceTable.get(world, balanceTableId, from);
        uint256 toBalance = BalanceTable.get(world, balanceTableId, to);
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        BalanceTable.set(world, balanceTableId, from, fromBalance - amount);
        BalanceTable.set(world, balanceTableId, to, toBalance + amount);

        ERC20Proxy(proxy).emitTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        uint256 _totalSupply = MetadataTable.getTotalSupply(world, metadataTableId);
        uint256 balance = BalanceTable.get(world, balanceTableId, account);
        
        MetadataTable.setTotalSupply(world, metadataTableId,  _totalSupply + amount);

        BalanceTable.set(world, balanceTableId, account, balance + amount);
        ERC20Proxy(proxy).emitTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = BalanceTable.get(world, balanceTableId, account);

        uint256 _totalSupply = MetadataTable.getTotalSupply(world, metadataTableId);
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        BalanceTable.set(world, balanceTableId, account, accountBalance - amount);
        MetadataTable.setTotalSupply(world, metadataTableId,  _totalSupply - amount);

        ERC20Proxy(proxy).emitTransfer(account, address(0), amount);
    }
    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        AllowanceTable.set(world, allowanceTableId, owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }

      ERC20Proxy(proxy).emitApproval(owner, spender, amount);
    }
}