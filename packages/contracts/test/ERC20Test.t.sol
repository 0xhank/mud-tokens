// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { ERC20Proxy, LibERC20 } from "mudtokens/src/tokens.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { ERC20TestToken, namespace, systemName } from "../src/systems/ERC20TestToken.sol";

contract ERC20Test is MudV2Test {
  IWorld public world;
  address public alice = address(uint160(0x6345659));
  address public bob = address(uint160(0x420));
  ERC20Proxy token;
  uint256 amount = 69;

  uint256 initialSupply = 1000;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    token = ERC20Proxy(LibERC20.proxy(world, namespace));
  }

  modifier prank(address prankster) {
    vm.startPrank(prankster);
    _;
    vm.stopPrank();
  }

  function testWorldExists() public {
    uint256 codeSize;
    address addr = worldAddress;
    assembly {
      codeSize := extcodesize(addr)
    }
    assertTrue(codeSize > 0);
  }

  function testName() external {
    string memory _name = token.name();
    assertEq("Test", _name);
  }

  function testSymbol() external {
    assertEq("TST", token.symbol());
  }

  function testMint() public {
    vm.startPrank(alice);
    world.mint20(amount);
    assertEq(token.balanceOf(alice), amount);
    assertEq(token.totalSupply(), amount);
  }

  function testBurn() public {
    testMint();
    world.burn20(amount);
    assertEq(token.balanceOf(alice), 0);
  }

  function testTransfer() public {
    testMint();
    vm.prank(alice);
    world.transfer20(bob, amount - 1);
    assertEq(token.balanceOf(bob), amount - 1);
    assertEq(token.totalSupply(), amount);
    assertEq(token.balanceOf(alice), 1);
  }

  function testPlace() public {
    testMint();
    vm.startPrank(alice);
    uint256 x = 49;
    uint256 y = 50;
    world.place20(amount, x, y);

    (uint256 retX, uint256 retY) = world.location20(amount);
    assertEq(retX, x);
    assertEq(retY, y);
  }
}
