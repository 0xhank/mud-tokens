// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { BalanceTable } from "../common/BalanceTable.sol";
import { AllowanceTable } from "../common/AllowanceTable.sol";
import { MetadataTable } from "../common/MetadataTable.sol";
import { ERC20_ALLOWANCE_T as ALLOWANCE, ERC20_BALANCE_T as BALANCE, ERC20_METADATA_T as METADATA } from "../common/constants.sol";
import { IERC20 } from "./interfaces/IERC20.sol";
import { IERC20Metadata } from "./interfaces/IERC20Metadata.sol";
import { ERC20Proxy } from "./ERC20Proxy.sol";

library LibERC20 {
  function from(bytes16 namespace, bytes16 _name) private pure returns (bytes32) {
    return ResourceSelector.from(namespace, _name);
  }

  /**
   * @dev Returns the name of the token.
   */
  function name(bytes16 namespace) internal view returns (string memory) {
    return MetadataTable.getName(from(namespace, METADATA));
  }

  function name(IBaseWorld world, bytes16 namespace) internal view returns (string memory) {
    return MetadataTable.getName(world, from(namespace, METADATA));
  }

  /**
   * @dev Returns the symbol of the token, usually a shorter version of the
   * name.
   */
  function symbol(bytes16 namespace) internal view returns (string memory) {
    return MetadataTable.getSymbol(from(namespace, METADATA));
  }

  function symbol(IBaseWorld world, bytes16 namespace) internal view returns (string memory) {
    return MetadataTable.getSymbol(world, from(namespace, METADATA));
  }

  function proxy(bytes16 namespace) internal view returns (address) {
    return MetadataTable.getProxy(from(namespace, METADATA));
  }

  function proxy(IBaseWorld world, bytes16 namespace) internal view returns (address) {
    return MetadataTable.getProxy(world, from(namespace, METADATA));
  }

  /**
   * @dev Returns the number of decimals used to get its user representation.
   * For example, if `decimals` equals `2`, a balance of `505` tokens should
   * be displayed to a user as `5.05` (`505 / 10 ** 2`).
   *
   * Tokens usually opt for a value of 18, imitating the relationship between
   * Ether and Wei. This is the default value returned by this function, unless
   * it's overridden.
   *
   * NOTE: This information is only used for _display_ purposes: it in
   * no way affects any of the arithmetic of the contract, including
   * {IERC20-balanceOf} and {IERC20-transfer}.
   */
  function decimals(bytes16 namespace) internal view returns (uint8) {
    return 18;
  }

  /**
   * @dev See {IERC20-totalSupply}.
   */
  function totalSupply(bytes16 namespace) internal view returns (uint256) {
    return MetadataTable.getTotalSupply(from(namespace, METADATA));
  }

  function totalSupply(IBaseWorld world, bytes16 namespace) internal view returns (uint256) {
    return MetadataTable.getTotalSupply(world, from(namespace, METADATA));
  }

  /**
   * @dev See {IERC20-balanceOf}.
   */
  function balanceOf(bytes16 namespace, address account) internal view returns (uint256) {
    return BalanceTable.get(from(namespace, BALANCE), account);
  }

  function balanceOf(IBaseWorld world, bytes16 namespace, address account) internal view returns (uint256) {
    return BalanceTable.get(world, from(namespace, BALANCE), account);
  }

  /**
   * @dev See {IERC20-transfer}.
   *
   * Requirements:
   *
   * - `to` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(bytes16 namespace, address msgSender, address to, uint256 amount) internal returns (bool) {
    address owner = msgSender;
    _transfer(namespace, owner, to, amount);
    return true;
  }

  function transfer(
    IBaseWorld world,
    bytes16 namespace,
    address msgSender,
    address to,
    uint256 amount
  ) internal returns (bool) {
    address owner = msgSender;
    _transfer(namespace, owner, to, amount);
    return true;
  }

  /**
   * @dev See {IERC20-allowance}.
   */
  function allowance(bytes16 namespace, address owner, address spender) internal view returns (uint256) {
    return AllowanceTable.get(from(namespace, ALLOWANCE), owner, spender);
  }

  function allowance(
    IBaseWorld world,
    bytes16 namespace,
    address owner,
    address spender
  ) internal view returns (uint256) {
    return AllowanceTable.get(world, from(namespace, ALLOWANCE), owner, spender);
  }

  /**
   * @dev See {IERC20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {ERC20}.
   *
   * NOTE: Does not update the allowance if the current allowance
   * is the maximum `uint256`.
   *
   * Requirements:
   *
   * - `from` and `to` cannot be the zero address.
   * - `from` must have a balance of at least `amount`.
   * - the caller must have allowance for ``from``'s tokens of at least
   * `amount`.
   */
  function transferFrom(
    bytes16 namespace,
    address msgSender,
    address _from,
    address to,
    uint256 amount
  ) internal returns (bool) {
    address spender = msgSender;
    _spendAllowance(namespace, _from, spender, amount);
    _transfer(namespace, _from, to, amount);
    return true;
  }

  function transferFrom(
    IBaseWorld world,
    bytes16 namespace,
    address msgSender,
    address _from,
    address to,
    uint256 amount
  ) internal returns (bool) {
    address spender = msgSender;
    _spendAllowance(world, namespace, _from, spender, amount);
    _transfer(world, namespace, _from, to, amount);
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {IERC20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(
    bytes16 namespace,
    address msgSender,
    address spender,
    uint256 addedValue
  ) internal returns (bool) {
    address owner = msgSender;
    _approve(namespace, owner, spender, allowance(namespace, owner, spender) + addedValue);
    return true;
  }

  function increaseAllowance(
    IBaseWorld world,
    bytes16 namespace,
    address msgSender,
    address spender,
    uint256 addedValue
  ) internal returns (bool) {
    address owner = msgSender;
    _approve(world, namespace, owner, spender, allowance(world, namespace, owner, spender) + addedValue);
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {IERC20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(
    bytes16 namespace,
    address msgSender,
    address spender,
    uint256 subtractedValue
  ) internal returns (bool) {
    address owner = msgSender;
    uint256 currentAllowance = allowance(namespace, owner, spender);
    require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    _approve(namespace, owner, spender, currentAllowance - subtractedValue);

    return true;
  }

  function decreaseAllowance(
    IBaseWorld world,
    bytes16 namespace,
    address msgSender,
    address spender,
    uint256 subtractedValue
  ) internal returns (bool) {
    address owner = msgSender;
    uint256 currentAllowance = allowance(world, namespace, owner, spender);
    require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    _approve(world, namespace, owner, spender, currentAllowance - subtractedValue);

    return true;
  }

  /**
   * @dev Moves `amount` of tokens from `from` to `to`.
   *
   * This internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `from` cannot be the zero address.
   * - `to` cannot be the zero address.
   * - `from` must have a balance of at least `amount`.
   */
  function _transfer(bytes16 namespace, address _from, address to, uint256 amount) internal {
    require(_from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");

    bytes32 selector = from(namespace, BALANCE);
    uint256 fromBalance = BalanceTable.get(selector, _from);
    require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    BalanceTable.set(selector, _from, fromBalance - amount);
    uint256 toBalance = BalanceTable.get(selector, to);
    BalanceTable.set(selector, to, toBalance + amount);

    emitTransfer(namespace, _from, to, amount);
  }

  function _transfer(IBaseWorld world, bytes16 namespace, address _from, address to, uint256 amount) internal {
    require(_from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");

    bytes32 selector = from(namespace, BALANCE);
    uint256 fromBalance = BalanceTable.get(world, selector, _from);
    require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    BalanceTable.set(world, selector, _from, fromBalance - amount);
    uint256 toBalance = BalanceTable.get(world, selector, to);
    BalanceTable.set(world, selector, to, toBalance + amount);

    emitTransfer(world, namespace, _from, to, amount);
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements:
   *
   * - `account` cannot be the zero address.
   */
  function _mint(bytes16 namespace, address account, uint256 amount) internal {
    require(account != address(0), "ERC20: mint to the zero address");
    uint256 _totalSupply = MetadataTable.getTotalSupply(from(namespace, METADATA));
    MetadataTable.setTotalSupply(from(namespace, METADATA), _totalSupply + amount);

    uint256 balance = BalanceTable.get(from(namespace, BALANCE), account);
    BalanceTable.set(from(namespace, BALANCE), account, balance + amount);
    emitTransfer(namespace, address(0), account, amount);
  }

  function _mint(IBaseWorld world, bytes16 namespace, address account, uint256 amount) internal {
    require(account != address(0), "ERC20: mint to the zero address");
    uint256 _totalSupply = MetadataTable.getTotalSupply(world, from(namespace, METADATA));
    MetadataTable.setTotalSupply(world, from(namespace, METADATA), _totalSupply + amount);

    uint256 balance = BalanceTable.get(world, from(namespace, BALANCE), account);
    BalanceTable.set(world, from(namespace, BALANCE), account, balance + amount);
    emitTransfer(world, namespace, address(0), account, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements:
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  function _burn(bytes16 namespace, address account, uint256 amount) internal {
    require(account != address(0), "ERC20: burn from the zero address");

    uint256 accountBalance = BalanceTable.get(from(namespace, BALANCE), account);
    require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    BalanceTable.set(from(namespace, BALANCE), account, accountBalance - amount);
    uint256 _totalSupply = MetadataTable.getTotalSupply(from(namespace, METADATA));
    MetadataTable.setTotalSupply(from(namespace, METADATA), _totalSupply - amount);

    emitTransfer(namespace, account, address(0), amount);
  }

  function _burn(IBaseWorld world, bytes16 namespace, address account, uint256 amount) internal {
    require(account != address(0), "ERC20: burn from the zero address");

    uint256 accountBalance = BalanceTable.get(world, from(namespace, BALANCE), account);
    require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    BalanceTable.set(from(namespace, BALANCE), account, accountBalance - amount);
    uint256 _totalSupply = MetadataTable.getTotalSupply(world, from(namespace, METADATA));
    MetadataTable.setTotalSupply(world, from(namespace, METADATA), _totalSupply - amount);

    emitTransfer(world, namespace, account, address(0), amount);
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
   *
   * This internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(bytes16 namespace, address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    AllowanceTable.set(from(namespace, ALLOWANCE), owner, spender, amount);
    emitApproval(namespace, owner, spender, amount);
  }

  function _approve(IBaseWorld world, bytes16 namespace, address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    AllowanceTable.set(world, from(namespace, ALLOWANCE), owner, spender, amount);
    emitApproval(world, namespace, owner, spender, amount);
  }

  /**
   * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
   *
   * Does not update the allowance amount in case of infinite allowance.
   * Revert if not enough allowance is available.
   *
   * Might emit an {Approval} event.
   */
  function _spendAllowance(bytes16 namespace, address owner, address spender, uint256 amount) internal {
    uint256 currentAllowance = allowance(namespace, owner, spender);
    if (currentAllowance != type(uint256).max) {
      require(currentAllowance >= amount, "ERC20: insufficient allowance");
      _approve(namespace, owner, spender, currentAllowance - amount);
    }
  }

  function _spendAllowance(
    IBaseWorld world,
    bytes16 namespace,
    address owner,
    address spender,
    uint256 amount
  ) internal {
    uint256 currentAllowance = allowance(world, namespace, owner, spender);
    if (currentAllowance != type(uint256).max) {
      require(currentAllowance >= amount, "ERC20: insufficient allowance");
      _approve(world, namespace, owner, spender, currentAllowance - amount);
    }
  }

  function emitTransfer(bytes16 namespace, address _from, address to, uint256 amount) internal {
    ERC20Proxy(proxy(namespace)).emitTransfer(_from, to, amount);
  }

  function emitTransfer(IBaseWorld world, bytes16 namespace, address _from, address to, uint256 amount) internal {
    ERC20Proxy(proxy(world, namespace)).emitTransfer(_from, to, amount);
  }

  function emitApproval(bytes16 namespace, address _from, address to, uint256 amount) internal {
    ERC20Proxy(proxy(namespace)).emitApproval(_from, to, amount);
  }

  function emitApproval(IBaseWorld world, bytes16 namespace, address _from, address to, uint256 amount) internal {
    ERC20Proxy(proxy(world, namespace)).emitApproval(_from, to, amount);
  }
}
