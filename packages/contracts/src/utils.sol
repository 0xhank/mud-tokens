// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SYSTEM_NAME as ERC20_SYSTEM} from "./token/erc20/ERC20System.sol";
import {SYSTEM_NAME as ERC721_SYSTEM} from "./token/erc721/ERC721System.sol";
import "@latticexyz/world/src/ResourceSelector.sol";

enum Token {
  ERC20,
  ERC721
}

function nameToBytes16(string memory name) pure returns (bytes16){
  return bytes16(keccak256(abi.encodePacked(name)));
}
function tokenToTable(string memory _name, Token token) pure returns (bytes32){
  bytes16 namespace = nameToBytes16(_name);
  bytes16 name;
  if(token == Token.ERC20) name = ERC20_SYSTEM;
  if(token == Token.ERC721) name = ERC721_SYSTEM;
  return ResourceSelector.from(namespace, name);
}

function toString(uint256 value) pure returns (string memory) {
        unchecked {
            uint256 length = log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10),"0123456789abcdef"))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }
function log10(uint256 value) pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }