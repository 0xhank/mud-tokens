// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { ResourceSelector, ROOT_NAMESPACE } from "@latticexyz/world/src/ResourceSelector.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { AllowanceTable, BalanceTable, MetadataTable } from "../codegen/Tables.sol";
import { ERC20_ALLOWANCE_T as ALLOWANCE, ERC20_BALANCE_T as BALANCE, ERC20_METADATA_T as METADATA } from "../common/constants.sol";
import { IERC20 } from "./interfaces/IERC20.sol";
import { IERC20Metadata } from "./interfaces/IERC20Metadata.sol";
import { ERC20Proxy } from "./ERC20Proxy.sol";

library LibERC20 {
  modifier onlyProxyWorld(bytes16 namespace) {
    ERC20Proxy _proxy = ERC20Proxy(proxy(namespace));
    require(address(_proxy.world()) == StoreSwitch.getStoreAddress(), "ERC20: invalid world");
    _;
  }

  function from(bytes16 namespace, bytes16 _name) private pure returns (bytes32) {
    return ResourceSelector.from(namespace, _name);
  }
  
  function name(bytes16 namespace) internal view returns (string memory) {
    return MetadataTable.getName(from(namespace, METADATA));
  }

  function name(IBaseWorld world, bytes16 namespace) internal view returns (string memory) {
    return MetadataTable.getName(world, from(namespace, METADATA));
  }

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
  
  function decimals(bytes16) internal pure returns (uint8) {
    return 18;
  }
  
  function decimals() internal pure returns (uint8) {
    return 18;
  }

  function totalSupply(bytes16 namespace) internal view returns (uint256) {
    return MetadataTable.getTotalSupply(from(namespace, METADATA));
  }

  function totalSupply(IBaseWorld world, bytes16 namespace) internal view returns (uint256) {
    return MetadataTable.getTotalSupply(world, from(namespace, METADATA));
  }
  
  function balanceOf(bytes16 namespace, address account) internal view returns (uint256) {
    return BalanceTable.get(from(namespace, BALANCE), account);
  }

  function balanceOf(IBaseWorld world, bytes16 namespace, address account) internal view returns (uint256) {
    return BalanceTable.get(world, from(namespace, BALANCE), account);
  }
  
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
    _transfer(world, namespace, owner, to, amount);
    return true;
  }
  
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

  function emitTransfer(bytes16 namespace, address _from, address to, uint256 amount) internal onlyProxyWorld(namespace){
    ERC20Proxy(proxy(namespace)).emitTransfer(_from, to, amount);
  }

  function emitTransfer(IBaseWorld world, bytes16 namespace, address _from, address to, uint256 amount) internal onlyProxyWorld(namespace) {
    ERC20Proxy(proxy(world, namespace)).emitTransfer(_from, to, amount);
  }

  function emitApproval(bytes16 namespace, address _from, address to, uint256 amount) internal onlyProxyWorld(namespace){
    ERC20Proxy(proxy(namespace)).emitApproval(_from, to, amount);
  }

  function emitApproval(IBaseWorld world, bytes16 namespace, address _from, address to, uint256 amount) internal onlyProxyWorld(namespace){
    ERC20Proxy(proxy(world, namespace)).emitApproval(_from, to, amount);
  }

  /* -------------------------------------------------------------------------- */
  /*                           INFERRED ROOT NAMESPACE                          */
  /* -------------------------------------------------------------------------- */

  function name() internal view returns (string memory) {
    return MetadataTable.getName(from(ROOT_NAMESPACE, METADATA));
  }

  function name(IBaseWorld world) internal view returns (string memory) {
    return MetadataTable.getName(world, from(ROOT_NAMESPACE, METADATA));
  }

  function symbol() internal view returns (string memory) {
    return MetadataTable.getSymbol(from(ROOT_NAMESPACE, METADATA));
  }

  function symbol(IBaseWorld world) internal view returns (string memory) {
    return MetadataTable.getSymbol(world, from(ROOT_NAMESPACE, METADATA));
  }

  function proxy() internal view returns (address) {
    return MetadataTable.getProxy(from(ROOT_NAMESPACE, METADATA));
  }

  function proxy(IBaseWorld world) internal view returns (address) {
    return MetadataTable.getProxy(world, from(ROOT_NAMESPACE, METADATA));
  }

  function totalSupply() internal view returns (uint256) {
    return MetadataTable.getTotalSupply(from(ROOT_NAMESPACE, METADATA));
  }

  function totalSupply(IBaseWorld world) internal view returns (uint256) {
    return MetadataTable.getTotalSupply(world, from(ROOT_NAMESPACE, METADATA));
  }
  
  function balanceOf(address account) internal view returns (uint256) {
    return BalanceTable.get(from(ROOT_NAMESPACE, BALANCE), account);
  }

  function balanceOf(IBaseWorld world, address account) internal view returns (uint256) {
    return BalanceTable.get(world, from(ROOT_NAMESPACE, BALANCE), account);
  }
  
  function transfer(address msgSender, address to, uint256 amount) internal returns (bool) {
    address owner = msgSender;
    _transfer(ROOT_NAMESPACE, owner, to, amount);
    return true;
  }

  function transfer(
    IBaseWorld world,
    address msgSender,
    address to,
    uint256 amount
  ) internal returns (bool) {
    address owner = msgSender;
    _transfer(world, ROOT_NAMESPACE, owner, to, amount);
    return true;
  }
  
  function allowance(address owner, address spender) internal view returns (uint256) {
    return AllowanceTable.get(from(ROOT_NAMESPACE, ALLOWANCE), owner, spender);
  }

  function allowance(
    IBaseWorld world,
    address owner,
    address spender
  ) internal view returns (uint256) {
    return AllowanceTable.get(world, from(ROOT_NAMESPACE, ALLOWANCE), owner, spender);
  }
  
  function transferFrom(
    address msgSender,
    address _from,
    address to,
    uint256 amount
  ) internal returns (bool) {
    address spender = msgSender;
    _spendAllowance(ROOT_NAMESPACE, _from, spender, amount);
    _transfer(ROOT_NAMESPACE, _from, to, amount);
    return true;
  }

  function transferFrom(
    IBaseWorld world,
    address msgSender,
    address _from,
    address to,
    uint256 amount
  ) internal returns (bool) {
    address spender = msgSender;
    _spendAllowance(world, ROOT_NAMESPACE, _from, spender, amount);
    _transfer(world, ROOT_NAMESPACE, _from, to, amount);
    return true;
  }
  
  function increaseAllowance(
    address msgSender,
    address spender,
    uint256 addedValue
  ) internal returns (bool) {
    address owner = msgSender;
    _approve(ROOT_NAMESPACE, owner, spender, allowance(ROOT_NAMESPACE, owner, spender) + addedValue);
    return true;
  }

  function increaseAllowance(
    IBaseWorld world,
    address msgSender,
    address spender,
    uint256 addedValue
  ) internal returns (bool) {
    address owner = msgSender;
    _approve(world, ROOT_NAMESPACE, owner, spender, allowance(world, ROOT_NAMESPACE, owner, spender) + addedValue);
    return true;
  }
  
  function decreaseAllowance(
    address msgSender,
    address spender,
    uint256 subtractedValue
  ) internal returns (bool) {
    address owner = msgSender;
    uint256 currentAllowance = allowance(ROOT_NAMESPACE, owner, spender);
    require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    _approve(ROOT_NAMESPACE, owner, spender, currentAllowance - subtractedValue);

    return true;
  }

  function decreaseAllowance(
    IBaseWorld world,
    address msgSender,
    address spender,
    uint256 subtractedValue
  ) internal returns (bool) {
    address owner = msgSender;
    uint256 currentAllowance = allowance(world, ROOT_NAMESPACE, owner, spender);
    require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    _approve(world, ROOT_NAMESPACE, owner, spender, currentAllowance - subtractedValue);

    return true;
  }
  
  function _transfer(address _from, address to, uint256 amount) internal {
    require(_from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");

    bytes32 selector = from(ROOT_NAMESPACE, BALANCE);
    uint256 fromBalance = BalanceTable.get(selector, _from);
    require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    BalanceTable.set(selector, _from, fromBalance - amount);
    uint256 toBalance = BalanceTable.get(selector, to);
    BalanceTable.set(selector, to, toBalance + amount);

    emitTransfer(ROOT_NAMESPACE, _from, to, amount);
  }

  function _transfer(IBaseWorld world, address _from, address to, uint256 amount) internal {
    require(_from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");

    bytes32 selector = from(ROOT_NAMESPACE, BALANCE);
    uint256 fromBalance = BalanceTable.get(world, selector, _from);
    require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    BalanceTable.set(world, selector, _from, fromBalance - amount);
    uint256 toBalance = BalanceTable.get(world, selector, to);
    BalanceTable.set(world, selector, to, toBalance + amount);

    emitTransfer(world, ROOT_NAMESPACE, _from, to, amount);
  }
  
  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "ERC20: mint to the zero address");
    uint256 _totalSupply = MetadataTable.getTotalSupply(from(ROOT_NAMESPACE, METADATA));
    MetadataTable.setTotalSupply(from(ROOT_NAMESPACE, METADATA), _totalSupply + amount);

    uint256 balance = BalanceTable.get(from(ROOT_NAMESPACE, BALANCE), account);
    BalanceTable.set(from(ROOT_NAMESPACE, BALANCE), account, balance + amount);
    emitTransfer(ROOT_NAMESPACE, address(0), account, amount);
  }

  function _mint(IBaseWorld world, address account, uint256 amount) internal {
    require(account != address(0), "ERC20: mint to the zero address");
    uint256 _totalSupply = MetadataTable.getTotalSupply(world, from(ROOT_NAMESPACE, METADATA));
    MetadataTable.setTotalSupply(world, from(ROOT_NAMESPACE, METADATA), _totalSupply + amount);

    uint256 balance = BalanceTable.get(world, from(ROOT_NAMESPACE, BALANCE), account);
    BalanceTable.set(world, from(ROOT_NAMESPACE, BALANCE), account, balance + amount);
    emitTransfer(world, ROOT_NAMESPACE, address(0), account, amount);
  }
  
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "ERC20: burn from the zero address");

    uint256 accountBalance = BalanceTable.get(from(ROOT_NAMESPACE, BALANCE), account);
    require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    BalanceTable.set(from(ROOT_NAMESPACE, BALANCE), account, accountBalance - amount);
    uint256 _totalSupply = MetadataTable.getTotalSupply(from(ROOT_NAMESPACE, METADATA));
    MetadataTable.setTotalSupply(from(ROOT_NAMESPACE, METADATA), _totalSupply - amount);

    emitTransfer(ROOT_NAMESPACE, account, address(0), amount);
  }

  function _burn(IBaseWorld world, address account, uint256 amount) internal {
    require(account != address(0), "ERC20: burn from the zero address");

    uint256 accountBalance = BalanceTable.get(world, from(ROOT_NAMESPACE, BALANCE), account);
    require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    BalanceTable.set(from(ROOT_NAMESPACE, BALANCE), account, accountBalance - amount);
    uint256 _totalSupply = MetadataTable.getTotalSupply(world, from(ROOT_NAMESPACE, METADATA));
    MetadataTable.setTotalSupply(world, from(ROOT_NAMESPACE, METADATA), _totalSupply - amount);

    emitTransfer(world, ROOT_NAMESPACE, account, address(0), amount);
  }
  
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    AllowanceTable.set(from(ROOT_NAMESPACE, ALLOWANCE), owner, spender, amount);
    emitApproval(ROOT_NAMESPACE, owner, spender, amount);
  }

  function _approve(IBaseWorld world, address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    AllowanceTable.set(world, from(ROOT_NAMESPACE, ALLOWANCE), owner, spender, amount);
    emitApproval(world, ROOT_NAMESPACE, owner, spender, amount);
  }
  
  function _spendAllowance(address owner, address spender, uint256 amount) internal {
    uint256 currentAllowance = allowance(ROOT_NAMESPACE, owner, spender);
    if (currentAllowance != type(uint256).max) {
      require(currentAllowance >= amount, "ERC20: insufficient allowance");
      _approve(ROOT_NAMESPACE, owner, spender, currentAllowance - amount);
    }
  }

  function _spendAllowance(
    IBaseWorld world,
    address owner,
    address spender,
    uint256 amount
  ) internal {
    uint256 currentAllowance = allowance(world, ROOT_NAMESPACE, owner, spender);
    if (currentAllowance != type(uint256).max) {
      require(currentAllowance >= amount, "ERC20: insufficient allowance");
      _approve(world, ROOT_NAMESPACE, owner, spender, currentAllowance - amount);
    }
  }

  function emitTransfer(address _from, address to, uint256 amount) internal onlyProxyWorld(ROOT_NAMESPACE){
    ERC20Proxy(proxy(ROOT_NAMESPACE)).emitTransfer(_from, to, amount);
  }

  function emitTransfer(IBaseWorld world, address _from, address to, uint256 amount) internal onlyProxyWorld(ROOT_NAMESPACE){
    ERC20Proxy(proxy(world, ROOT_NAMESPACE)).emitTransfer(_from, to, amount);
  }

  function emitApproval(address _from, address to, uint256 amount) internal onlyProxyWorld(ROOT_NAMESPACE){
    ERC20Proxy(proxy(ROOT_NAMESPACE)).emitApproval(_from, to, amount);
  }

  function emitApproval(IBaseWorld world, address _from, address to, uint256 amount) internal onlyProxyWorld(ROOT_NAMESPACE){
    ERC20Proxy(proxy(world, ROOT_NAMESPACE)).emitApproval(_from, to, amount);
  }
}
