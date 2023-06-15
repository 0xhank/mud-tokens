// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudV2Test } from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import {ERC721Proxy} from "@latticexyz/world/src/modules/tokens/erc721/ERC721Proxy.sol";
import {ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import {LibERC721} from "@latticexyz/world/src/modules/tokens/erc721/LibERC721.sol";
import {ERC721TestToken, namespace, systemName} from "../src/ERC721TestToken.sol";

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


  function call(bytes memory args) public returns (bytes memory) {
      return world.call(namespace, systemName, args);
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

    function testMint() prank(alice) public {
        call(abi.encodeWithSelector(ERC721TestToken.mint.selector, tokenId));
        assertEq(token.ownerOf(69), alice);
        assertEq(token.totalSupply(), 1);
        assertEq(token.balanceOf(alice), 1);
    }

    function testBurn() public {
       testMint();

        call(abi.encodeWithSelector(ERC721TestToken.burn.selector, tokenId));
        vm.expectRevert("ERC721: invalid token ID");
        token.ownerOf(tokenId); // Reverts
    }

    function testTransfer() public {
      testMint();
      vm.prank(alice); 
      call(abi.encodeWithSelector(ERC721TestToken.transfer.selector, bob, tokenId));
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
      call(abi.encodeWithSelector(ERC721TestToken.place.selector, tokenId, x, y));
      bytes memory rawLocation = call(abi.encodeWithSelector(ERC721TestToken.location.selector, tokenId));
      (uint256 retX, uint256 retY) = abi.decode(rawLocation, (uint256, uint256));
      assertEq(retX, x);
      assertEq(retY, y);
    }

}
