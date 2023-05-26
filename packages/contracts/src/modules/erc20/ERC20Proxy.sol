// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IERC20Proxy.sol";
import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import {ERC20System } from "./ERC20System.sol";
import { BalanceTable } from "../common/BalanceTable.sol";
import { AllowanceTable} from "../common/AllowanceTable.sol";
import { MetadataTable } from "../common/MetadataTable.sol";
import {tokenToTable, Token, nameToBytes16} from "../common/utils.sol";
import {ERC20_SYSTEM_NAME, BALANCE_TABLE_NAME, METADATA_TABLE_NAME, ALLOWANCE_TABLE_NAME} from "../common/constants.sol";
import { console } from "forge-std/console.sol";

contract ERC20Proxy is IERC20Proxy {

    IBaseWorld world;
    bytes32 immutable balanceTableId;
    bytes32 immutable metadataTableId;
    bytes32 immutable allowanceTableId;

    constructor (IBaseWorld _world, string memory _name) {
      world= _world;
      balanceTableId = tokenToTable(_name, BALANCE_TABLE_NAME);
      metadataTableId = tokenToTable(_name, METADATA_TABLE_NAME);
      allowanceTableId = tokenToTable(_name, ALLOWANCE_TABLE_NAME);
    }

    function name() public view virtual override returns (string memory){
      return MetadataTable.getName(world, metadataTableId);
    }

    function symbol() public view virtual override returns (string memory){
      return MetadataTable.getSymbol(world, metadataTableId);
    }

    function decimals() public view virtual override returns (uint8){
      return 18;
    }

    function totalSupply() public view virtual override returns (uint256){
      return MetadataTable.getTotalSupply(world, metadataTableId);
    }

    function balanceOf(address account) public view virtual override returns (uint256){
      return BalanceTable.get(world, balanceTableId, account);
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool){
      _transfer(msg.sender, to, amount);
      return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256){
      return AllowanceTable.get(world, allowanceTableId, owner, spender);
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool){
      _approve(msg.sender, spender, amount);
      return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool){
      _spendAllowance(from, msg.sender, amount);
      _transfer(from, to, amount);
      return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
      address owner = msg.sender;
      _approve(owner, spender, allowance(owner, spender) + addedValue);
      return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = BalanceTable.get(world, balanceTableId, from);
        uint256 toBalance = BalanceTable.get(world, balanceTableId, to);
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        BalanceTable.set(world, balanceTableId, from, fromBalance - amount);
        BalanceTable.set(world, balanceTableId, to, toBalance + amount);

        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        uint256 _totalSupply = MetadataTable.getTotalSupply(world, metadataTableId);
        uint256 balance = BalanceTable.get(world, balanceTableId, account);
        
        MetadataTable.setTotalSupply(world, metadataTableId,  _totalSupply + amount);

        BalanceTable.set(world, balanceTableId, account, balance + amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = BalanceTable.get(world, balanceTableId, account);

        uint256 _totalSupply = MetadataTable.getTotalSupply(world, metadataTableId);
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        BalanceTable.set(world, balanceTableId, account, accountBalance - amount);
        MetadataTable.setTotalSupply(world, metadataTableId,  _totalSupply - amount);

        emit Transfer(account, address(0), amount);
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

      emit Approval(owner, spender, amount);
    }

    function emitApproval(address owner, address spender, uint256 value) public virtual {
      bytes memory rawSystemAddress = world.call(nameToBytes16(name()), ERC20_SYSTEM_NAME, abi.encodeWithSelector(ERC20System.getAddress.selector));
      require(msg.sender == address(world) || msg.sender == abi.decode(rawSystemAddress, (address)), "ERC20: Only World or MUD token can emit approval event");

      emit Approval(owner, spender, value);
    }

    function emitTransfer(address from, address to, uint256 value) public virtual {
      bytes memory rawSystemAddress = world.call(nameToBytes16(name()), ERC20_SYSTEM_NAME, abi.encodeWithSelector(ERC20System.getAddress.selector));
      address systemAddress = abi.decode(rawSystemAddress, (address));
      require(msg.sender == address(world) || msg.sender == systemAddress, "ERC20: Only World or MUD token can emit transfer event");
      emit Transfer(from, to, value);
    }
}