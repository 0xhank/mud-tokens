// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

function tokenToTable(address tokenId, bytes16 name) pure returns (bytes32) {
      bytes16 token = addressToBytes16((tokenId));
      return bytes32(abi.encodePacked(token, name));
}

function addressToBytes16(address addr) pure returns (bytes16) {
    bytes16 result;
    assembly {
        result := addr
    }
    return result;
}

bytes16 constant ERC20 = bytes16('ERC20');
bytes16 constant ALLOWANCE = bytes16('ERC20_ALLOWANCE');

address constant SingletonKey = address(uint160(0x060D));