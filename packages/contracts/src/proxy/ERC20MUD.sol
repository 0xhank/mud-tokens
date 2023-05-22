// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IERC20MUD.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import {ERC20TestTokenMUD } from "../systems/ERC20TestTokenMUD.sol";
import {ERC20System, SYSTEM_NAME} from "../systems/ERC20System.sol";
import { ERC20, addressToBytes16} from "../utils.sol";
import { console } from "forge-std/console.sol";

contract ERC20MUD is IERC20MUD {

    IWorld immutable world;
    ERC20TestTokenMUD immutable token;
    bytes16 immutable mudId;
    constructor(IWorld _world, string memory _name, string memory _symbol) {
      world =_world;
      mudId = addressToBytes16(address(this));
      token = new ERC20TestTokenMUD(world, address(this), _name, _symbol);
    }

    function name() public view virtual override returns (string memory){
      return token.name();
    }

    function symbol() public view virtual override returns (string memory){
      return token.symbol();
    }

    function decimals() public view virtual override returns (uint8){
      return 18;
    }

    function totalSupply() public view virtual override returns (uint256){
      return token.totalSupply();
    }

    function balanceOf(address account) public view virtual override returns (uint256){
      return token.balanceOf(account);
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool){
      _transfer(msg.sender, to, amount);
      return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256){
      return token.allowance(owner, spender);
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

    function _transfer(address from, address to, uint256 amount) internal virtual {
      world.call(
        mudId,
        SYSTEM_NAME,
        abi.encodeWithSelector(
          ERC20System.transferBypass.selector,
          from,
          to,
          amount
        )
      );
    }

    function _mint (address account, uint256 amount) internal virtual {
      console.log('account:', account);
      console.log('amount:', amount);
      world.call(
        mudId,
        SYSTEM_NAME,
        abi.encodeWithSelector(
          ERC20System.mintBypass.selector,
          account,
          amount
        )
      );
    }

    function _burn (address account, uint256 amount) internal virtual {
      world.call(
        mudId,
        SYSTEM_NAME,
        abi.encodeWithSelector(
          ERC20System.burnBypass.selector,
          account,
          amount
        )
      );
    }

    function _approve (address owner, address spender, uint256 amount) internal virtual {
        world.call(
        mudId,
        SYSTEM_NAME,
        abi.encodeWithSelector(
          ERC20System.approveBypass.selector,
          owner,
          spender,
          amount
        )
      );
    }

    function _spendAllowance (address owner, address spender, uint256 amount) internal virtual {
      world.call(
        mudId,
        SYSTEM_NAME,
        abi.encodeWithSelector(
          ERC20System.spendAllowanceBypass.selector,
          owner,
          spender,
          amount
        )
      );

    }

    function emitApproval(address owner, address spender, uint256 value) public virtual {
      require(msg.sender == address(world) || msg.sender == address(token), "ERC20: Only World or MUD token can emit approval event");
      emit Approval(owner, spender, value);
    }

    function emitTransfer(address from, address to, uint256 value) public virtual {
      require(msg.sender == address(world) || msg.sender == address(token), "ERC20: Only World or MUD token can emit transfer event");
      emit Transfer(from, to, value);
    }
}