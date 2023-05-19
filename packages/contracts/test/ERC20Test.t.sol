// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudV2Test } from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { SampleToken } from "./SampleToken.sol";
import {ERC20System, SingletonKey} from "../src/systems/ERC20System.sol";
import { ERC20TokenTable } from "../src/codegen/Tables.sol";


contract ERC20Test is MudV2Test {
  IWorld public world;
  SampleToken public sampleToken;
  address public alice = address(uint160(0x69));
  address public tokenId;

  uint256 initialSupply = 1000;
  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    sampleToken = new SampleToken(address(world), alice, initialSupply);
    tokenId = address(sampleToken);
  }

  function testWorldExists() public {
    uint256 codeSize;
    address addr = worldAddress;
    assembly {
      codeSize := extcodesize(addr)
    }
    assertTrue(codeSize > 0);
  }

  function testCreate() public {
    uint256 aliceTokens = ERC20TokenTable.getBalance(world, tokenId, alice);
    assertEq(aliceTokens, initialSupply);

    aliceTokens = sampleToken.balanceOf(alice);
    assertEq(aliceTokens, initialSupply);

    uint256 supply = sampleToken.totalSupply();

    assertEq(supply, initialSupply);

    string memory mudName = ERC20TokenTable.getName(world, tokenId, SingletonKey);
    string memory proxyName = sampleToken.name();

    assertEq(mudName, proxyName);

  }

}
