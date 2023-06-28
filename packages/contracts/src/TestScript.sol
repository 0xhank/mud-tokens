// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { ERC721Registration } from "@latticexyz/world/src/modules/tokens/erc721/ERC721Registration.sol";
import { ERC1155Registration } from "@latticexyz/world/src/modules/tokens/erc1155/ERC1155Registration.sol";
import { ERC20Registration } from "@latticexyz/world/src/modules/tokens/erc20/ERC20Registration.sol";
import { TokenLocation } from "./codegen/tables/TokenLocation.sol";
import { ERC721TestToken, systemName } from "./systems/ERC721TestToken.sol";
import { ERC1155TestToken, systemName as ERC1155System } from "./systems/ERC1155TestToken.sol";
import { namespace, locationTableName as tableName } from "./constants.sol";

library TestScript {
  function run(address worldAddress) internal {
    IBaseWorld world = IBaseWorld(worldAddress);

    ERC721Registration.install(world, namespace, "Test", "TST");
    ERC20Registration.install(world, namespace, "Test", "TST");
    ERC1155Registration.install(world, namespace, "Test");
  }
}
