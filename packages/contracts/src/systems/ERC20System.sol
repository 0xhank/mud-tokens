// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";
import "../interfaces/IERC20Metadata.sol";
import {addressToEntityKey} from "../addressToEntityKey.sol";

import { System } from "@latticexyz/world/src/System.sol";
import { ERC20TokenTable } from "../codegen/Tables.sol";
import { AllowanceTable } from "../codegen/Tables.sol";

address constant SingletonKey = address(uint160(0x060D));


contract ERC20System is System {
    /**
     * @dev Sets the values for {name} and {symbol} and {proxy}.
     * These values are immutable: they can only be set once (ideally during postDeploy script) 
     */
    function initializeMetadata(uint256 tokenId, address _proxy, string calldata _name, string calldata _symbol) public {
      require(ERC20TokenTable.lengthName(tokenId, SingletonKey) == 0, "ERC20: Metadata already initialized");
      ERC20TokenTable.setProxy(tokenId, SingletonKey, _proxy);
      ERC20TokenTable.setName(tokenId, SingletonKey, _name);
      ERC20TokenTable.setSymbol(tokenId, SingletonKey, _symbol);
    }

    function name(uint256 tokenId) public view returns (string memory) {
        return ERC20TokenTable.getName(tokenId, SingletonKey);
    }

    function symbol(uint256 tokenId) public view returns (string memory) {
        return ERC20TokenTable.getSymbol(tokenId, SingletonKey);
    }
  
    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply(uint256 tokenId) public view  returns (uint256) {
        return ERC20TokenTable.getTotalSupply(tokenId, SingletonKey);
    }

    function balanceOf(uint256 tokenId, address account) public view  returns (uint256) {
        return ERC20TokenTable.getBalance(tokenId, account);
    }

    function transfer(uint256 tokenId, address to, uint256 amount) public  returns (bool) {
        address owner = _msgSender();
        _transfer(tokenId, owner, to, amount);
        return true;
    }

    function allowance(uint256 tokenId, address owner, address spender) public view  returns (uint256) {
        return AllowanceTable.get(tokenId, owner, spender);
    }

    
    function approve(uint256 tokenId, address spender, uint256 amount) public {
        address owner = _msgSender();
        _approve(tokenId, owner, spender, amount);
    }

    function transferFrom(uint256 tokenId, address from, address to, uint256 amount) public {
        address spender = _msgSender();
        _spendAllowance(tokenId, from, spender, amount);
        _transfer(tokenId, from, to, amount);
    }
    
    function increaseAllowance(uint256 tokenId, address spender, uint256 addedValue) public virtual {
        address owner = _msgSender();
        _approve(tokenId, owner, spender, allowance(tokenId, owner, spender) + addedValue);
    }

    function decreaseAllowance(uint256 tokenId, address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(tokenId, owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(tokenId, owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    
    function _transfer(uint256 tokenId, address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = ERC20TokenTable.getBalance(tokenId, from);
        uint256 toBalance = ERC20TokenTable.getBalance(tokenId, to);
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            ERC20TokenTable.setBalance(tokenId, from, fromBalance - amount);
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.

            ERC20TokenTable.setBalance(tokenId, to, toBalance + amount);
        }

        // emit transfer
    }

    
    function _mint(uint256 tokenId, address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        uint256 _totalSupply = ERC20TokenTable.getTotalSupply(tokenId, SingletonKey);
        uint256 balance = ERC20TokenTable.getBalance(tokenId, account);
        ERC20TokenTable.setTotalSupply(tokenId, SingletonKey, _totalSupply + amount);

        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            ERC20TokenTable.setBalance(tokenId, account, balance + amount);
        }

        // emit transfer

    }
    
    function _burn(uint256 tokenId, address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = ERC20TokenTable.getBalance(tokenId, account);

        uint256 _totalSupply = ERC20TokenTable.getTotalSupply(tokenId, SingletonKey);
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        unchecked {
            ERC20TokenTable.setBalance(tokenId, account, accountBalance - amount);
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            ERC20TokenTable.setTotalSupply(tokenId, SingletonKey, _totalSupply - amount);
        }

        // emit transfer
    }
    
    function _approve(uint256 tokenId, address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        AllowanceTable.set(tokenId, owner, spender, amount);
    }
    
    function _spendAllowance(uint256 tokenId, address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(tokenId, owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(tokenId, owner, spender, currentAllowance - amount);
            }
        }

        // emit approval
    }
}