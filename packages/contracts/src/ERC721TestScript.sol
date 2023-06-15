// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { ERC721Registration } from "@latticexyz/world/src/modules/tokens/erc721/ERC721Registration.sol";
import {TokenLocation} from "./codegen/tables/TokenLocation.sol";
import { ERC721TestToken, namespace, tableName, systemName } from "./ERC721TestToken.sol";

library ERC721TestScript {
  function run(address worldAddress ) internal{
    IBaseWorld world = IBaseWorld(worldAddress);

    ERC721Registration.install(world, namespace, "Test", "TST");

    world.registerTable(namespace, tableName, TokenLocation.getSchema(), TokenLocation.getKeySchema());

    //register the rest of the namespace's functionality like normal
    ERC721TestToken testToken = new ERC721TestToken();
    world.registerSystem(namespace, systemName, testToken, true);

  }
}
