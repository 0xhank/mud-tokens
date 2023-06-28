// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudV2Test } from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { LibERC1155, ERC1155Proxy } from "@latticexyz/world/src/modules/tokens/Tokens.sol";
import { ERC1155TestToken, namespace, systemName } from "../src/systems/ERC1155TestToken.sol";

contract ERC1155Test is MudV2Test {
  IWorld public world;
  address public alice = address(uint160(0x6345659));
  address public bob = address(uint160(0x420));
  ERC1155Proxy token;
  uint256 tokenId = 69;
  uint256 amount = 69;

  uint256 initialSupply = 1000;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    token = ERC1155Proxy(LibERC1155.proxy(world, namespace));
  }

  function call(bytes memory args) public returns (bytes memory) {
    return world.call(namespace, systemName, args);
  }

  modifier prank(address prankster) {
    vm.startPrank(prankster);
    _;
    vm.stopPrank();
  }

  function testURI() external {
    string memory _uri = token.uri(9);
    assertEq("Test", _uri);
  }

  function testMint() public prank(alice) {
    world.mint1155(tokenId, amount);
    assertEq(token.balanceOf(alice, tokenId), 69);
  }

  function testBurn() public {
    testMint();
    vm.startPrank(alice);
    world.burn1155(tokenId, amount - 1);
    assertEq(token.balanceOf(alice, tokenId), 1);

    world.burn1155(tokenId, 1);

    assertEq(token.balanceOf(alice, tokenId), 0);
    vm.stopPrank();
  }

  function testTransfer() public {
    testMint();
    vm.startPrank(alice);
    world.transfer1155(bob, tokenId, amount - 1);
    assertEq(token.balanceOf(bob, tokenId), amount - 1);
    assertEq(token.balanceOf(alice, tokenId), 1);
    vm.stopPrank();
  }

  function testPlace() public {
    testMint();
    vm.startPrank(alice);
    uint256 x = 49;
    uint256 y = 50;
    world.place1155(tokenId, x, y);
    (uint256 retX, uint256 retY) = world.location1155(tokenId);
    assertEq(retX, x);
    assertEq(retY, y);
    vm.stopPrank();
  }
}
