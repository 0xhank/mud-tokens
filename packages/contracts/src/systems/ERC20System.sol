// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { ERC20Table } from "../codegen/Tables.sol";
// import { ERC20TestToken} from "./ERC20TestToken.sol";
import { AllowanceTable } from "../codegen/Tables.sol";
import { IERC20MUD } from "../proxy/interfaces/IERC20MUD.sol"; 
import { ERC20MUD } from "../proxy/ERC20MUD.sol"; 
import { console } from "forge-std/console.sol";
import {SingletonKey, ERC20, ALLOWANCE, tokenToTable, addressToBytes16} from "../utils.sol";

bytes16 constant SYSTEM_NAME = bytes16('erc20_system');

contract ERC20System is System {

    /**
     * @dev Sets the values for {name} and {symbol}.
     * These values are immutable: they can only be set once (ideally during postDeploy script) 
     */
    IWorld immutable world;
    address tokenId;
    bytes32 immutable ERC20Id;
    bytes32 immutable allowanceId;
    constructor(IWorld _world, address _tokenId, string memory _name, string memory _symbol) {
      world = _world;
      tokenId = _tokenId;
      bytes16 namespace = addressToBytes16(tokenId);

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

      ERC20Id = world.registerTable(namespace, ERC20, ERC20Table.getSchema(), ERC20Table.getKeySchema());
      allowanceId = world.registerTable(namespace, ALLOWANCE, AllowanceTable.getSchema(), AllowanceTable.getKeySchema());

      ERC20Table.setName(world, ERC20Id, SingletonKey, _name);
      ERC20Table.setSymbol(world, allowanceId, SingletonKey, _symbol);
    }

    function name() public view virtual returns (string memory) {
        return ERC20Table.getName(world, ERC20Id, SingletonKey);
    }

    function symbol() public view virtual returns (string memory) {
        return ERC20Table.getSymbol(world, allowanceId, SingletonKey);
    }
  
    function totalSupply() public view  virtual returns (uint256) {
        return ERC20Table.getTotalSupply(world, ERC20Id, SingletonKey);
    }

    function balanceOf(address account) public view  virtual returns (uint256) {
        return ERC20Table.getBalance(world, ERC20Id, account);
    }

    function transfer(address to, uint256 amount) public virtual{
        address owner = _msgSender();
        _transfer(owner, to, amount);
    }

    function allowance(address owner, address spender) public virtual view returns (uint256) {
        return AllowanceTable.get(world, allowanceId, owner, spender);
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
      require(_msgSender() == tokenId, "ERC20System: not authorized to transfer");
      _transfer(from, to, amount);
    }
    function mintBypass(address account, uint256 amount) virtual public {
      require(_msgSender() == tokenId, "ERC20System: not authorized to mint");
      _mint(account, amount);
    }

    function burnBypass(address account, uint256 amount) virtual public {
      require(_msgSender() == tokenId, "ERC20System: not authorized to burn");
      _burn(account, amount);
    } 

    function approveBypass(address owner, address spender, uint256 amount) public {
      require(_msgSender() == tokenId, "ERC20System: not authorized to approve");
      _approve(owner, spender, amount);
    }

    function spendAllowanceBypass(address owner, address spender, uint256 amount) public {
      require(_msgSender() == tokenId, "ERC20System: not authorized to spend allowance");
      _spendAllowance(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = ERC20Table.getBalance(world, ERC20Id, from);
        uint256 toBalance = ERC20Table.getBalance(world, ERC20Id, to);
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        ERC20Table.setBalance(world, ERC20Id, from, fromBalance - amount);
        ERC20Table.setBalance(world, ERC20Id, to, toBalance + amount);

        IERC20MUD(tokenId).emitTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal {
      console.log('account:', account);
      console.log('amount:', amount);
        require(account != address(0), "ERC20: mint to the zero address");
        uint256 _totalSupply = ERC20Table.getTotalSupply(world, ERC20Id, SingletonKey);
        uint256 balance = ERC20Table.getBalance(world, ERC20Id, account);
        
        ERC20Table.setTotalSupply(world, ERC20Id, SingletonKey, _totalSupply + amount);

        ERC20Table.setBalance(world, ERC20Id, account, balance + amount);
        IERC20MUD(tokenId).emitTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = ERC20Table.getBalance(world, ERC20Id, account);

        uint256 _totalSupply = ERC20Table.getTotalSupply(world, ERC20Id, SingletonKey);
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        ERC20Table.setBalance(world, ERC20Id, account, accountBalance - amount);
        ERC20Table.setTotalSupply(world, ERC20Id, SingletonKey, _totalSupply - amount);

        IERC20MUD(tokenId).emitTransfer(account, address(0), amount);
    }
    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        AllowanceTable.set(world, allowanceId, owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }

      IERC20MUD(tokenId).emitApproval(owner, spender, amount);
    }
}