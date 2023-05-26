// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { BalanceTable } from "../common/BalanceTable.sol";
import { AllowanceTable} from "../common/AllowanceTable.sol";
import { MetadataTable } from "../common/MetadataTable.sol";

import { ERC20Proxy } from "./ERC20Proxy.sol"; 
import {nameToBytes16, tokenToTable, Token} from "../common/utils.sol";
import {METADATA_TABLE_NAME, BALANCE_TABLE_NAME, ALLOWANCE_TABLE_NAME} from "../common/constants.sol";
import '@latticexyz/world/src/ResourceSelector.sol';
import { console } from "forge-std/console.sol";


contract ERC20System is System {

    bytes32 immutable private metadataTableId;
    bytes32 immutable balanceTableId;
    bytes32 immutable allowanceTableId;
    
    constructor(string memory namespaceString) {
      bytes16 namespace = nameToBytes16(namespaceString);
      metadataTableId = ResourceSelector.from(namespace, METADATA_TABLE_NAME);
      balanceTableId = ResourceSelector.from(namespace, BALANCE_TABLE_NAME);
      allowanceTableId = ResourceSelector.from(namespace, ALLOWANCE_TABLE_NAME);
    }

    function name() public view virtual returns (string memory) {
        return MetadataTable.getName(metadataTableId);
    }

    function symbol() public view virtual returns (string memory) {
        return MetadataTable.getSymbol(metadataTableId);
    }

    function proxy() public view virtual returns (address){
      return MetadataTable.getProxy(metadataTableId);
    }

    function getAddress() public view returns (address){
      return address(this);
    }
  
    function totalSupply() public view  virtual returns (uint256) {
        return MetadataTable.getTotalSupply(metadataTableId);
    }

    function balanceOf(address account) public view  virtual returns (uint256) {
        return BalanceTable.get(balanceTableId, account);
    }

    function transfer(address to, uint256 amount) public virtual{
        address owner = _msgSender();
        _transfer(owner, to, amount);
    }

    function allowance(address owner, address spender) public virtual view returns (uint256) {
        return AllowanceTable.get(allowanceTableId, owner, spender);
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

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = BalanceTable.get(balanceTableId, from);
        uint256 toBalance = BalanceTable.get(balanceTableId, to);
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        BalanceTable.set(balanceTableId, from, fromBalance - amount);
        BalanceTable.set(balanceTableId, to, toBalance + amount);

        emitTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        uint256 _totalSupply = MetadataTable.getTotalSupply(metadataTableId);
        uint256 balance = BalanceTable.get(balanceTableId, account);
        
        MetadataTable.setTotalSupply(metadataTableId,  _totalSupply + amount);

        BalanceTable.set(balanceTableId, account, balance + amount);
        emitTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = BalanceTable.get(balanceTableId, account);

        uint256 _totalSupply = MetadataTable.getTotalSupply(metadataTableId);
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        BalanceTable.set(balanceTableId, account, accountBalance - amount);
        MetadataTable.setTotalSupply(metadataTableId,  _totalSupply - amount);
    }
    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        AllowanceTable.set(allowanceTableId, owner, spender, amount);
        ERC20Proxy(proxy()).emitApproval(owner, spender, amount);

    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }

    }

    function emitTransfer(address from, address to, uint256 amount) private { 
      console.log('msg sender:', msg.sender);
      console.log('this:', address(this));
      ERC20Proxy(proxy()).emitTransfer(from, to, amount);
    }
}