// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { ERC20Table } from "../codegen/Tables.sol";
import { AllowanceTable } from "../codegen/Tables.sol";
import { IERC20MUD } from "../proxy/interfaces/IERC20MUD.sol"; 
import { ERC20MUD } from "../proxy/ERC20MUD.sol"; 
import { console } from "forge-std/console.sol";

address constant SingletonKey = address(uint160(0x060D));


contract ERC20System is System {
    /**
     * @dev Sets the values for {name} and {symbol}.
     * These values are immutable: they can only be set once (ideally during postDeploy script) 
     */
    function initializeERC20(address tokenId, string calldata _name, string calldata _symbol) public {
      require(ERC20Table.lengthName(tokenId, SingletonKey) == 0, "ERC20: Token already initialized");
      ERC20Table.setName(tokenId, SingletonKey, _name);
      ERC20Table.setSymbol(tokenId, SingletonKey, _symbol);
    }

    function nameERC20(address tokenId) public view returns (string memory) {
        return ERC20Table.getName(tokenId, SingletonKey);
    }
    function symbolERC20(address tokenId) public view returns (string memory) {
        return ERC20Table.getSymbol(tokenId, SingletonKey);
    }
  
    function totalSupplyERC20(address tokenId) public view  returns (uint256) {
        return ERC20Table.getTotalSupply(tokenId, SingletonKey);
    }

    function balanceOfERC20(address tokenId, address account) public view  returns (uint256) {
        return ERC20Table.getBalance(tokenId, account);
    }

    function transferERC20(address tokenId, address to, uint256 amount) public {
        address owner = _msgSender();
        _transfer(tokenId, owner, to, amount);
    }

    function allowanceERC20(address tokenId, address owner, address spender) public view returns (uint256) {
        return AllowanceTable.get(tokenId, owner, spender);
    }
    
    function approveERC20(address tokenId, address spender, uint256 amount) public {
        address owner = _msgSender();
        _approve(tokenId, owner, spender, amount);
    }

    function transferFromERC20(address tokenId, address from, address to, uint256 amount) public {
        address spender = _msgSender();
        _spendAllowance(tokenId, from, spender, amount);
        _transfer(tokenId, from, to, amount);
    }
    
    function increaseAllowanceERC20(address tokenId, address spender, uint256 addedValue) public virtual {
        address owner = _msgSender();
        _approve(tokenId, owner, spender, allowanceERC20(tokenId, owner, spender) + addedValue);
    }

    function decreaseAllowanceERC20(address tokenId, address spender, uint256 subtractedValue) public virtual {
        address owner = _msgSender();
        uint256 currentAllowance = allowanceERC20(tokenId, owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(tokenId, owner, spender, currentAllowance - subtractedValue);
    }

    function transferERC20(address tokenId, address from, address to, uint256 amount) public {
      require(_msgSender() == tokenId, "ERC20System: not authorized to transfer");
      _transfer(tokenId, from, to, amount);
    }

    function mintERC20(address tokenId, address account, uint256 amount) public {
      require(_msgSender() == tokenId, "ERC20System: not authorized to mint");
      _mint(tokenId, account, amount);
    }

    function burnERC20(address tokenId, address account, uint256 amount) public {
      require(_msgSender() == tokenId, "ERC20System: not authorized to burn");
      _burn(tokenId, account, amount);
    } 

    function approveERC20(address tokenId, address owner, address spender, uint256 amount) public {
      require(_msgSender() == tokenId, "ERC20System: not authorized to approve");
      _approve(tokenId, owner, spender, amount);
    }

    function spendAllowanceERC20(address tokenId, address owner, address spender, uint256 amount) public {
      require(_msgSender() == tokenId, "ERC20System: not authorized to spend allowance");
      _spendAllowance(tokenId, owner, spender, amount);
    }

    function _transfer(address tokenId, address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = ERC20Table.getBalance(tokenId, from);
        uint256 toBalance = ERC20Table.getBalance(tokenId, to);
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        ERC20Table.setBalance(tokenId, from, fromBalance - amount);
        ERC20Table.setBalance(tokenId, to, toBalance + amount);

        IERC20MUD(tokenId).emitTransfer(from, to, amount);
    }

    function _mint(address tokenId, address account, uint256 amount) private {
        require(account != address(0), "ERC20: mint to the zero address");
        uint256 _totalSupply = ERC20Table.getTotalSupply(tokenId, SingletonKey);
        uint256 balance = ERC20Table.getBalance(tokenId, account);
        
        ERC20Table.setTotalSupply(tokenId, SingletonKey, _totalSupply + amount);

        ERC20Table.setBalance(tokenId, account, balance + amount);
        IERC20MUD(tokenId).emitTransfer(address(0), account, amount);
    }

    function _burn(address tokenId, address account, uint256 amount) private {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = ERC20Table.getBalance(tokenId, account);

        uint256 _totalSupply = ERC20Table.getTotalSupply(tokenId, SingletonKey);
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        ERC20Table.setBalance(tokenId, account, accountBalance - amount);
        ERC20Table.setTotalSupply(tokenId, SingletonKey, _totalSupply - amount);

        IERC20MUD(tokenId).emitTransfer(account, address(0), amount);
    }
    
    function _approve(address tokenId, address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        AllowanceTable.set(tokenId, owner, spender, amount);
    }

    

    function _spendAllowance(address tokenId, address owner, address spender, uint256 amount) private {
        uint256 currentAllowance = allowanceERC20(tokenId, owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(tokenId, owner, spender, currentAllowance - amount);
        }

      IERC20MUD(tokenId).emitApproval(owner, spender, amount);
    }
}