// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "forge-std/Test.sol";

import { MudV2Test } from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { ERC721TestProxy  } from "../src/token/erc721/ERC721TestProxy.sol";
import {nameToBytes16} from "../src/utils.sol";

contract NftTest is MudV2Test {
  IWorld public world;
  ERC721TestProxy public token;
  address public alice = address(uint160(0x69));
  address public bob = address(uint160(0x420));
  address public tokenId;
  bytes16 public tableId;

  uint256 testTokenId = 69;
  //Setup Function
  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    token = new ERC721TestProxy(world, "GOKU", "GK");
    tokenId = address(token);
    tableId = nameToBytes16("GOKU");
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
      assertEq("GOKU",token.name());
   }

    function testSymbol() external {
      console.log('symbol:', token.symbol());
        assertEq("GK", token.symbol());
    }

    function testMint() public {
      token.mint(alice, testTokenId);
      assertEq(1, token.balanceOf(alice));
      assertEq(token.ownerOf(testTokenId), alice);
      assertEq(token.totalSupply(), 1);
    }

    function testMintURI() public {
      token.mint(alice, testTokenId, 'yomama');
      assertEq(token.tokenURI(testTokenId), 'yomama');
    }

    function testBurn() public {
      token.mint(address(this), testTokenId);
      token.burn(testTokenId);
      assertEq(token.balanceOf(alice), 0);
      vm.expectRevert();
      token.burn(testTokenId);
    }

    function testApprove() public {
      token.mint(address(this), testTokenId);
      token.approve(alice, testTokenId);
      assertEq(token.getApproved(testTokenId), alice);
    }

    function testApproveForAll() public {
      token.mint(address(this), testTokenId);
      token.setApprovalForAll(alice, true);
      assertTrue(token.isApprovedForAll(address(this), alice));
    }

    function testTransferFromOwner() public {
      token.mint(address(this), testTokenId);
      token.transferFrom(address(this), alice, testTokenId);
      assertEq(token.ownerOf(testTokenId), alice);
      assertEq(token.balanceOf(address(this)),0);
      assertEq(token.balanceOf(alice),1);
    }

    function testTransferFromApproved() public {
      address thisAddress = address(this);
      token.mint(thisAddress, testTokenId);
      token.approve(alice, testTokenId);
      vm.prank(alice);
      token.transferFrom(thisAddress, alice, testTokenId);
      assertEq(token.ownerOf(testTokenId), alice);
      assertEq(token.balanceOf(address(this)),0);
      assertEq(token.balanceOf(alice),1);
      assertEq(token.getApproved(testTokenId), address(0));
    }
    
    function testSafeTransfer() public {
      token.mint(address(this), testTokenId);
      token.safeTransferFrom(address(this), alice, testTokenId);
      assertEq(token.ownerOf(testTokenId), alice);
      assertEq(token.balanceOf(address(this)),0);
      assertEq(token.balanceOf(alice),1);
    }
}