// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

function addressToBytes16(address addr) pure returns (bytes16) {
    bytes16 result;
    assembly {
        result := addr
    }
    return result;
}