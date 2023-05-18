// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IERC20MUD.sol";
import { IWorld } from "../codegen/world/IWorld.sol";

contract ERC20MUD is IERC20MUD {

    IWorld private world;
    uint256 private tokenId;
    
    constructor(address _worldAddress, uint256 _tokenId, string memory _name, string memory _symbol) {
      world = IWorld(_worldAddress);
      tokenId = _tokenId;
      world.initializeERC20(_tokenId, address(this), _name, _symbol);
    }

    function name() public view virtual override returns (string memory){
      return world.nameERC20(tokenId);
    }

    function symbol() public view virtual override returns (string memory){
      return world.symbolERC20(tokenId);
    }

    function decimals() public view virtual override returns (uint8){
      return 18;
    }

    function totalSupply() public view virtual override returns (uint256){
      return world.totalSupplyERC20(tokenId);
    }

    function balanceOf(address account) public view virtual override returns (uint256){
      return world.balanceOfERC20(tokenId, account);
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool){
      (bool success, ) = address(world).delegatecall(
        abi.encodeWithSignature("transferERC20(uint256, address, uint256", tokenId, to, amount));
      return success;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256){
      return world.allowanceERC20(tokenId, owner, spender);
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool){
      (bool success, ) = address(world).delegatecall(
        abi.encodeWithSignature("approveERC20(uint256, address, uint256", tokenId, spender, amount));

      return success;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool){
      (bool success, ) = address(world).delegatecall(
        abi.encodeWithSignature("transferFromERC20(uint256, address, address, uint256", tokenId, from, to, amount));

      return success;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
      (bool success, ) = address(world).delegatecall(
        abi.encodeWithSignature("increaseAllowanceERC20(uint256, address, uint256", tokenId, spender, addedValue));

      return success;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
      (bool success, ) = address(world).delegatecall(
        abi.encodeWithSignature("decreaseAllowanceERC20(uint256, address, uint256", tokenId, spender, subtractedValue));

      return success;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
      world.transferERC20(tokenId, from, to, amount);
    }

    function _mint (address account, uint256 amount) internal virtual {
      world.mint(tokenId, account, amount);
    }

    function _burn (address account, uint256 amount) internal virtual {
      world.burn(tokenId, account, amount);
    }

    function _approve (address owner, address spender, uint256 amount) internal virtual {
      world.approve(tokenId, owner, spender, amount);
    }

    function _spendAllowance (address owner, address spender, uint256 amount) internal virtual {
      world.spendAllowance(tokenId, owner, spender, amount);
    }

    function emitApproval(address owner, address spender, uint256 value) external {
      require(msg.sender == address(world), "ERC20: Only World can emit approval event");
      emit Approval(owner, spender, value);
    }

    function emitTransfer(address from, address to, uint256 value) external {
      require(msg.sender == address(world), "ERC20: Only World can emit transfer event");
      emit Approval(from, to, value);
    }
}