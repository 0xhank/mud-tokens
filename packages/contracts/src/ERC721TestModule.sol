// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { IModule } from "@latticexyz/world/src/interfaces/IModule.sol";
import { ERC721Proxy } from "@latticexyz/world/src/modules/tokens/erc721/ERC721Proxy.sol";
import { ERC721TestToken, namespace, tableName } from "./ERC721TestToken.sol";
import { WorldContext } from "@latticexyz/world/src/WorldContext.sol";
import { ERC721Registration } from "@latticexyz/world/src/modules/tokens/erc721/ERC721Registration.sol";
import { ERC721_S } from "@latticexyz/world/src/modules/tokens/common/constants.sol";

contract ERC721TestModule is IModule, WorldContext {
  // this trick circumvents the issue of file size too large
  ERC721Registration registration = new ERC721Registration();

  function getName() public pure returns (bytes16) {
    return bytes16("ERC721Test.m");
  }

  function install(bytes memory args) public {
    (string memory _name, string memory _symbol) = abi.decode(args, (string, string));
    IBaseWorld world = IBaseWorld(_world());

    ERC721TestToken testToken = new ERC721TestToken();

    // Delegate call so the world owner is this contract instead of ERC721
    (
      address(registration).delegatecall(
        abi.encodeWithSignature(
          "install(address,bytes16,string,string,address)",
          world,
          namespace,
          _name,
          _symbol,
          testToken
        )
      )
    );

    // register additional tables and function selectors the extended token contract uses
    // TODO: make this autogenerate in the tokengen script
    world.registerFunctionSelector(namespace, ERC721_S, "mint", "(address, uint256)");
    world.registerFunctionSelector(namespace, ERC721_S, "burn", "(uint256)");
    world.registerFunctionSelector(namespace, ERC721_S, "transfer", "(address, uint256)");
  }
}
