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

// Design problem: We want there to be different functionality for different tokens.
// Since a token's id is generated after the creation of this system (during contract deployment), there is no way to parse the tokenId beforehand.
// This system needs to be deployed alongside the proxy contract and the tokenId needs to be injected into the tokenId slot.
// This is a non-option because devs cant build their smart contracts in a js script lol 
// The other option is to predetermine the tokenId here and manually assign that id to the proxy contract, but this is also sub-ideal.
// The other option is to have a system that gatekeeps these systems to a certain tokenId, but that also doesn't make sense
// The other option is to deploy a separate

contract ERC20TestTokenSystem is System{
  function mint(address tokenId, address to, uint256 amount) public {
    _mint(tokenId, to, amount);
  }

  function burn(address tokenId, address from, uint256 amount) public {
    _burn(tokenId, from, amount);
  }

  // Since worlds don't allow system inheritance, we need to redefine the private functions here.

  function _mint(address tokenId, address account, uint256 amount) private {
        require(account != address(0), "ERC20: mint to the zero address");
        uint256 _totalSupply = ERC20Table.getTotalSupply(tokenId, SingletonKey);
        uint256 balance = ERC20Table.getBalance(tokenId, account);
        
        ERC20Table.setTotalSupply(tokenId, SingletonKey, _totalSupply + amount);
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
        ERC20Table.setBalance(tokenId, account, balance + amount);

        // emit transfer
      IERC20MUD(tokenId).emitTransfer(address(0), account, amount);
    }

    function _burn(address tokenId, address account, uint256 amount) private {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = ERC20Table.getBalance(tokenId, account);

        uint256 _totalSupply = ERC20Table.getTotalSupply(tokenId, SingletonKey);
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        unchecked {
            ERC20Table.setBalance(tokenId, account, accountBalance - amount);
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            ERC20Table.setTotalSupply(tokenId, SingletonKey, _totalSupply - amount);
        }

        // emit transfer
      IERC20MUD(tokenId).emitTransfer(account, address(0), amount);
    }
}