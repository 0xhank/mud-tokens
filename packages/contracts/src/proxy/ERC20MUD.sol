// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IERC20MUD.sol";
import { IWorld } from "../codegen/world/IWorld.sol";

contract ERC20MUD is IERC20MUD {

    IWorld private world;
    
    constructor(address _worldAddress, string memory _name, string memory _symbol) {
      world = IWorld(_worldAddress);
      world.initializeERC20(address(this), _name, _symbol);
    }

    function name() public view virtual override returns (string memory){
      return world.nameERC20(address(this));
    }

    function symbol() public view virtual override returns (string memory){
      return world.symbolERC20(address(this));
    }

    function decimals() public view virtual override returns (uint8){
      return 18;
    }

    function totalSupply() public view virtual override returns (uint256){
      return world.totalSupplyERC20(address(this));
    }

    function balanceOf(address account) public view virtual override returns (uint256){
      return world.balanceOfERC20(address(this), account);
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool){
      _transfer(msg.sender, to, amount);
      return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256){
      return world.allowanceERC20(address(this), owner, spender);
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
      world.transferERC20(address(this), from, to, amount);
    }

    function _mint (address account, uint256 amount) internal virtual {
      world.mintERC20(address(this), account, amount);
    }

    function _burn (address account, uint256 amount) internal virtual {
      world.burnERC20(address(this), account, amount);
    }

    function _approve (address owner, address spender, uint256 amount) internal virtual {
      world.approveERC20(address(this), owner, spender, amount);
    }

    function _spendAllowance (address owner, address spender, uint256 amount) internal virtual {
      world.spendAllowanceERC20(address(this), owner, spender, amount);
    }

    function emitApproval(address owner, address spender, uint256 value) public virtual {
      require(msg.sender == address(world), "ERC20: Only World can emit approval event");
      emit Approval(owner, spender, value);
    }

    function emitTransfer(address from, address to, uint256 value) public virtual {
      require(msg.sender == address(world), "ERC20: Only World can emit transfer event");
      emit Approval(from, to, value);
    }
}