// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";

interface IERC20Proxy is IERC20, IERC20Metadata {
  function emitApproval(address owner, address spender, uint256 value) external;

  function emitTransfer(address from, address to, uint256 value) external;
}