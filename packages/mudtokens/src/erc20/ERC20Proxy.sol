// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IERC165 } from "../common/IERC165.sol";
import { IERC20 } from "./interfaces/IERC20.sol";
import { IERC20Metadata } from "./interfaces/IERC20Metadata.sol";
import { LibERC20 } from "./LibERC20.sol";
import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";
import { LibERC20 } from "./LibERC20.sol";

contract ERC20Proxy is IERC20, IERC20Metadata {
  IBaseWorld private world;
  bytes16 private immutable namespace;

  constructor(IBaseWorld _world, bytes16 _namespace) {
    world = _world;
    namespace = _namespace;
  }

  modifier onlySystemOrWorld() {
    // is there a system within the namespace that exists at the msg.sender address?
    if (msg.sender != address(world) && msg.sender != address(this)) {
      bytes32 systemId = SystemRegistry.get(world, msg.sender);
      require(
        ResourceSelector.getNamespace(systemId) == namespace,
        "ERC20: Only World or system or this contract can execute call"
      );
    }
    _;
  }

  /**
   * @dev See {IERC20Metadata-name}.
   */
  function name() public view virtual override returns (string memory) {
    return LibERC20.name(world, namespace);
  }

  /**
   * @dev See {IERC20Metadata-symbol}.
   */
  function symbol() public view virtual override returns (string memory) {
    return LibERC20.symbol(world, namespace);
  }

  function decimals() public view virtual override returns (uint8) {
    return 18;
  }

  function totalSupply() public view virtual returns (uint256) {
    return LibERC20.totalSupply(world, namespace);
  }

  /**
   * @dev See {IERC20-balanceOf}.
   */
  function balanceOf(address owner) public view virtual override returns (uint256) {
    return LibERC20.balanceOf(world, namespace, owner);
  }

  /**
   * @dev See {IERC20-transferFrom}.
   */
  function transfer(address to, uint256 amount) public virtual override returns (bool) {
    LibERC20.transfer(world, namespace, msg.sender, to, amount);
    return true;
  }

  function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return LibERC20.allowance(world, namespace, owner, spender);
  }

  function approve(address spender, uint256 amount) public virtual override returns (bool) {
    address owner = msg.sender;
    _approve(owner, spender, amount);
    return true;
  }

  function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
    LibERC20.transferFrom(world, namespace, msg.sender, from, to, amount);
    return true;
  }

  function _mint(address account, uint256 amount) internal virtual {
    LibERC20._mint(world, namespace, account, amount);
  }

  function _burn(address account, uint256 amount) internal virtual {
    LibERC20._burn(world, namespace, account, amount);
  }

  function _transfer(address from, address to, uint256 amount) internal virtual {
    LibERC20._transfer(world, namespace, from, to, amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal virtual {
    LibERC20._approve(world, namespace, owner, spender, amount);
  }

  /**
   * @dev Emitted when `owner` enables `approved` to manage the `amount` token.
   */
  function emitApproval(address owner, address approved, uint256 amount) public onlySystemOrWorld {
    emit Approval(owner, approved, amount);
  }

  /**
   * @dev Emitted when `owner` enables `approved` to manage the `amount` token.
   */
  function emitTransfer(address from, address to, uint256 amount) public onlySystemOrWorld {
    emit Transfer(from, to, amount);
  }
}
