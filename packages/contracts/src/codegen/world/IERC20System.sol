// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

interface IERC20System {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function proxy() external view returns (address);

  function getAddress() external view returns (address);

  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address to, uint256 amount) external;

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external;

  function transferFrom(address from, address to, uint256 amount) external;

  function increaseAllowance(address spender, uint256 addedValue) external;

  function decreaseAllowance(address spender, uint256 subtractedValue) external;
}
