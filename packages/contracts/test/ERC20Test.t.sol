// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudV2Test } from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { ERC20TestToken } from "./ERC20TestToken.sol";
import {ERC20TestTokenSystem, SingletonKey} from "../src/systems/ERC20TestTokenSystem.sol";
import { ERC20Table } from "../src/codegen/Tables.sol";

// I took these tests from https://github.com/Atarpara/openzeppeline-erc20-foundry-test
contract ERC20Test is MudV2Test {
  IWorld public world;
  ERC20TestToken public token;
  address public alice = address(uint160(0x69));
  address public bob = address(uint160(0x420));
  address public tokenId;

  uint256 initialSupply = 1000;
  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    token = new ERC20TestToken(address(world), "GOKU", "GK");
    tokenId = address(token);
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
      assertEq("GOKU",token.name());
   }

    function testSymbol() external {
        assertEq("GK", token.symbol());
    }

    function testMint() public {
        token.mint(alice, 2e18);
        assertEq(token.totalSupply(), token.balanceOf(alice));
    }

    function testBurn() public {
        token.mint(alice, 10e18);
        assertEq(token.balanceOf(alice),10e18);
        
        token.burn(alice, 8e18);

        assertEq(token.totalSupply(), 2e18);
        assertEq(token.balanceOf(alice),2e18);
    }
    function testApprove() public {
        assertTrue(token.approve(alice, 1e18));
        assertEq(token.allowance(address(this),alice), 1e18);
    }

    function testIncreaseAllowance() external {
        assertEq(token.allowance(address(this), alice), 0);
        assertTrue(token.increaseAllowance(alice , 2e18));
        assertEq(token.allowance(address(this), alice), 2e18);
    }

    function testDescreaseAllowance() external {
        testApprove();
        assertTrue(token.decreaseAllowance(alice, 0.5e18));
        assertEq(token.allowance(address(this), alice), 0.5e18);
    }

    function testTransfer() external {
        testMint();
        vm.startPrank(alice);
        token.transfer(bob, 0.5e18);
        assertEq(token.balanceOf(bob), 0.5e18);
        assertEq(token.balanceOf(alice), 1.5e18);
        vm.stopPrank();
    }

    function testTransferFrom() external {
        testMint();
        vm.prank(alice);
        token.approve(address(this), 1e18);
        assertTrue(token.transferFrom(alice, bob, 0.7e18));
        assertEq(token.allowance(alice, address(this)), 1e18 - 0.7e18);
        assertEq(token.balanceOf(alice), 2e18 - 0.7e18);
        assertEq(token.balanceOf(bob), 0.7e18);
    }

    function testFailMintToZero() external {
        token.mint(address(0), 1e18);
    }

    function testFailBurnFromZero() external {
        token.burn(address(0) , 1e18);
    }

    function testFailBurnInsufficientBalance() external {
        testMint();
        vm.prank(alice);
        token.burn(alice, 3e18);
    }

    function testFailApproveToZeroAddress() external {
        token.approve(address(0), 1e18);
    }

//!!!
    function testFailApproveFromZeroAddress() external {
        vm.prank(address(0));
        token.approve(alice, 1e18);
    }

//!!!
    function testFailTransferToZeroAddress() external {
        testMint();
        vm.prank(alice);
        token.transfer(address(0), 1e18);
    }

    function testFailTransferFromZeroAddress() external {
        testBurn();
        vm.prank(address(0));
        token.transfer(alice , 1e18);
    }

    function testFailTransferInsufficientBalance() external {
        testMint();
        vm.prank(alice);
        token.transfer(bob , 3e18);
    }

    function testFailTransferFromInsufficientApprove() external {
        testMint();
        vm.prank(alice);
        token.approve(address(this), 1e18);
        token.transferFrom(alice, bob, 2e18);
    }

    function testFailTransferFromInsufficientBalance() external {
        testMint();
        vm.prank(alice);
        token.approve(address(this), type(uint).max);

        token.transferFrom(alice, bob, 3e18);
    }

    /* CALLING FROM WORLD */
    function testNameWorld() external {
      assertEq("GOKU", world.nameERC20(tokenId));
    }
    

    function testSymbolWorld() external {
        assertEq("GK", world.symbolERC20(tokenId));
    }

    function testMintWorld() public {
        world.mint(tokenId, alice, 2e18);
        assertEq(token.totalSupply(), token.balanceOf(alice));
    }

    function testBurnWorld() public {
        world.mint(tokenId, alice, 10e18);
        assertEq(world.balanceOfERC20(tokenId, alice),10e18);
        
        world.burn(tokenId, alice, 8e18);

        assertEq(world.totalSupplyERC20(tokenId), 2e18);
        assertEq(world.balanceOfERC20(tokenId, alice),2e18);
    }
    function testApproveWorld() public {
        world.approveERC20(tokenId, alice, 1e18);
        assertEq(world.allowanceERC20(tokenId, address(this),alice), 1e18);
    }

    function testIncreaseAllowanceWorld() external {
        assertEq(world.allowanceERC20(tokenId, address(this), alice), 0);
        world.increaseAllowanceERC20(tokenId, alice , 2e18);
        assertEq(world.allowanceERC20(tokenId, address(this), alice), 2e18);
    }

    function testDescreaseAllowanceWorld() external {
        testApprove();
        world.decreaseAllowanceERC20(tokenId, alice, 0.5e18);
        assertEq(world.allowanceERC20(tokenId, address(this), alice), 0.5e18);
    }

    function testTransferWorld() external {
        testMint();
        vm.startPrank(alice);
        world.transferERC20(tokenId, bob, 0.5e18);
        assertEq(world.balanceOfERC20(tokenId, bob), 0.5e18);
        assertEq(world.balanceOfERC20(tokenId, alice), 1.5e18);
        vm.stopPrank();
    }

    function testTransferFromWorld() external {
        testMint();
        vm.prank(alice);
        world.approveERC20(tokenId, address(this), 1e18);
        world.transferFromERC20(tokenId, alice, bob, 0.7e18);
        assertEq(world.allowanceERC20(tokenId, alice, address(this)), 1e18 - 0.7e18);
        assertEq(world.balanceOfERC20(tokenId, alice), 2e18 - 0.7e18);
        assertEq(world.balanceOfERC20(tokenId, bob), 0.7e18);
    }

    function testFailMintToZeroWorld() external {
        world.mint(tokenId, address(0), 1e18);
    }

    function testFailBurnFromZeroWorld() external {
        world.burn(tokenId, address(0) , 1e18);
    }

    function testFailBurnInsufficientBalanceWorld() external {
        testMint();
        vm.prank(alice);
        world.burn(tokenId, alice, 3e18);
    }

    function testFailApproveToZeroAddressWorld() external {
        world.approveERC20(tokenId, address(0), 1e18);
    }

    function testFailApproveFromZeroAddressWorld() external {
        vm.prank(address(0));
        world.approveERC20(tokenId, alice, 1e18);
    }

    function testFailTransferToZeroAddressWorld() external {
        testMint();
        vm.prank(alice);
        world.transferERC20(tokenId, address(0), 1e18);
    }

    function testFailTransferFromZeroAddressWorld() external {
        testBurn();
        vm.prank(address(0));
        world.transferERC20(tokenId, alice , 1e18);
    }

    function testFailTransferInsufficientBalanceWorld() external {
        testMint();
        vm.prank(alice);
        world.transferERC20(tokenId, bob , 3e18);
    }

    function testFailTransferFromInsufficientApproveWorld() external {
        testMint();
        vm.prank(alice);
        world.approveERC20(tokenId, address(this), 1e18);
        world.transferFromERC20(tokenId, alice, bob, 2e18);
    }

    function testFailTransferFromInsufficientBalanceWorld() external {
        testMint();
        vm.prank(alice);
        world.approveERC20(tokenId, address(this), type(uint).max);

        world.transferFromERC20(tokenId, alice, bob, 3e18);
    }

    /*****************************/
    /*      Fuzz Testing         */
    /*****************************/

    function testFuzzMint(address to, uint256 amount) external {
        vm.assume(to != address(0));
        token.mint(to,amount);
        assertEq(token.totalSupply(), token.balanceOf(to));
    }

    function testFuzzBurn(address from, uint256 mintAmount, uint256 burnAmount) external {
        vm.assume(from != address(0));              // from address must not zero
        burnAmount = bound(burnAmount, 0, mintAmount);    // if burnAmount > mintAmount then bound burnAmount to 0 to mintAmount
        token.mint(from , mintAmount);
        token.burn(from, burnAmount);
        assertEq(token.totalSupply() , mintAmount - burnAmount);
        assertEq(token.balanceOf(from), mintAmount - burnAmount);
    }

    function testFuzzApprove(address to, uint256 amount) external {
        vm.assume(to != address(0));
        assertTrue(token.approve(to,amount));
        assertEq(token.allowance(address(this),to), amount);
    }

    function testFuzzTransfer(address to, uint256 amount) external {
        vm.assume(to != address(0));
        vm.assume(to != address(this));
        token.mint(address(this), amount);
        
        assertTrue(token.transfer(to,amount));
        assertEq(token.balanceOf(address(this)), 0);
        assertEq(token.balanceOf(to), amount);
    }

    function testFuzzTransferFrom(address from, address to,uint256 approval, uint256 amount) external {
        vm.assume(from != address(0));
        vm.assume(to != address(0));

        amount = bound(amount, 0, approval);
        token.mint(from, amount);

        vm.prank(from);
        assertTrue(token.approve(address(this), approval));

        assertTrue(token.transferFrom(from, to, amount));
        assertEq(token.totalSupply(), amount);

        if (approval == type(uint256).max){
            assertEq(token.allowance(from, address(this)), approval);
        }
        else {
            assertEq(token.allowance(from,address(this)), approval - amount);
        }

        if (from == to) {
            assertEq(token.balanceOf(from), amount);
        } else {
            assertEq(token.balanceOf(from), 0);
            assertEq(token.balanceOf(to), amount);
        }
    }

    function testFailFuzzBurnInsufficientBalance(address to, uint256 mintAmount, uint256 burnAmount) external {
        burnAmount = bound(burnAmount, mintAmount+1, type(uint256).max);

        token.mint(to, mintAmount);
        token.burn(to, burnAmount);
    }

    function testFailTransferInsufficientBalance(address to, uint256 mintAmount, uint256 sendAmount) external {
        sendAmount = bound(sendAmount, mintAmount + 1, type(uint256).max);

        token.mint(address(this), mintAmount);
        token.transfer(to, sendAmount);
    }

    function testFailFuzzTransferFromInsufficientApprove(address from, address to,uint256 approval, uint256 amount) external {
        amount = bound(amount, approval+1, type(uint256).max);

        token.mint(from, amount);
        vm.prank(from);
        token.approve(address(this), approval);
        token.transferFrom(from, to, amount);
    }

    function testFailFuzzTransferFromInsufficientBalance(address from, address to, uint256 mintAmount, uint256 sentAmount) external {
        sentAmount = bound(sentAmount, mintAmount+1, type(uint256).max);

        token.mint(from, mintAmount);
        vm.prank(from);
        token.approve(address(this), type(uint256).max);

        token.transferFrom(from, to, sentAmount);
    }
}
