// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudV2Test } from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { ERC721Proxy } from "@latticexyz/world/src/modules/tokens/erc721/ERC721Proxy.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { LibERC721 } from "@latticexyz/world/src/modules/tokens/erc721/LibERC721.sol";
import { ERC721TestToken, namespace, systemName } from "../src/systems/ERC721TestToken.sol";

contract ERC721Test is MudV2Test {
  IWorld public world;
  address public alice = address(uint160(0x6345659));
  address public bob = address(uint160(0x420));
  ERC721Proxy token;
  uint256 tokenId = 69;

  uint256 initialSupply = 1000;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    token = ERC721Proxy(LibERC721.proxy(world, namespace));
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

  function testMint() public prank(alice) {
    world.mint721(tokenId);
    assertEq(token.ownerOf(69), alice);
    assertEq(token.totalSupply(), 1);
    assertEq(token.balanceOf(alice), 1);
  }

  function testBurn() public {
    testMint();
    world.burn721(tokenId);
    vm.expectRevert("ERC721: invalid token ID");
    token.ownerOf(tokenId); // Reverts
  }

  function testTransfer() public {
    testMint();
    vm.prank(alice);
    world.transfer721(bob, tokenId);
    assertEq(token.ownerOf(69), bob);
    assertEq(token.totalSupply(), 1);
    assertEq(token.balanceOf(bob), 1);
    assertEq(token.balanceOf(alice), 0);
  }

  function testPlace() public {
    testMint();
    vm.startPrank(alice);
    uint256 x = 49;
    uint256 y = 50;
    world.place721(tokenId, x, y);

    (uint256 retX, uint256 retY) = world.location721(tokenId);
    assertEq(retX, x);
    assertEq(retY, y);
  }
}
