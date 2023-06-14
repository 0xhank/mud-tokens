// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudV2Test } from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import { ERC721_S, METADATA_T } from "../tokens/common/constants.sol";
import { MetadataTable } from "../tokens/common/MetadataTable.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import {ERC721Proxy} from "../tokens/erc721/ERC721Proxy.sol";
import {ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import {LibERC721} from "../tokens/erc721/LibERC721.sol";
import {ERC721TestToken, namespace} from "../src/ERC721TestToken.sol";
import { ResourceType } from "@latticexyz/world/src/modules/core/tables/ResourceType.sol";
import { Resource } from "@latticexyz/world/src/Types.sol";

// I took these tests from https://github.com/Atarpara/openzeppeline-erc20-foundry-test
contract ERC721Test is MudV2Test {
  IWorld public world;
  address public alice = address(uint160(0x6345659));
  address public bob = address(uint160(0x420));
  uint256 tokenId = 69;

  uint256 initialSupply = 1000;
  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
  }

  function token() private returns (ERC721Proxy _token){
    address proxy =MetadataTable.getProxy(world, ResourceSelector.from(namespace, METADATA_T));
    _token = ERC721Proxy(proxy);
  }

  function call(bytes memory args) public returns (bytes memory) {
      return world.call(namespace, ERC721_S, args);
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
      string memory _name = token().name();
      assertEq("ERC721Test", _name);
   }

    // function testSymbol() external {
    //     assertEq("ERC", token.symbol());
    // }

    // function testMint() prank(alice) public {
    //     call(abi.encodeWithSelector(ERC721TestToken.mint.selector, tokenId));
    //     assertEq(token.ownerOf(69), alice);
    //     assertEq(token.totalSupply(), 1);
    //     assertEq(token.balanceOf(alice), 1);
    // }

    // function testBurn() public {
    //    testMint();

    //     call(abi.encodeWithSelector(ERC721TestToken.burn.selector, tokenId));
    //     vm.expectRevert("ERC721: invalid token ID");
    //     token.ownerOf(tokenId); // Reverts
    // }

    // function testTransfer() public {
    //   testMint();
    //   vm.prank(alice); 
    //   call(abi.encodeWithSelector(ERC721TestToken.transfer.selector, bob, tokenId));
    //   assertEq(token.ownerOf(69), bob);
    //   assertEq(token.totalSupply(), 1);
    //   assertEq(token.balanceOf(bob), 1);
    //   assertEq(token.balanceOf(alice), 0);
    // }

    // function testPlace() public {
    //   testMint();
    //   vm.startPrank(alice);
    //   uint256 x = 49;
    //   uint256 y = 50;
    //   call(abi.encodeWithSelector(ERC721TestToken.place.selector, tokenId, x, y));
    //   bytes memory rawLocation = call(abi.encodeWithSelector(ERC721TestToken.location.selector, tokenId));
    //   (uint256 retX, uint256 retY) = abi.decode(rawLocation, (uint256, uint256));
    //   assertEq(retX, x);
    //   assertEq(retY, y);
    // }

}
