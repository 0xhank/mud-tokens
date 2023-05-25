// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudV2Test } from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import { ERC20System } from "../src/modules/erc20/ERC20System.sol";
import {ERC20_SYSTEM_NAME} from "../src/modules/common/constants.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import {ERC20TestSystem} from "../src/ERC20TestSystem.sol";
import {ERC20Proxy} from "../src//modules/erc20/ERC20Proxy.sol";
import {ERC20Module} from "../src/modules/erc20/ERC20Module.sol";
import {nameToBytes16} from "../src/modules/common/utils.sol";

// I took these tests from https://github.com/Atarpara/openzeppeline-erc20-foundry-test
contract ERC20Test is MudV2Test {
  IWorld public world;
  address public alice = address(uint160(0x69));
  address public bob = address(uint160(0x420));
  bytes16 public namespace;
  ERC20Proxy public token;  

  uint256 initialSupply = 1000;
  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    string memory name = "ERC20Test";
    string memory symbol = "ERC";

    namespace = nameToBytes16(name);
    bytes memory proxy = world.call(namespace, ERC20_SYSTEM_NAME, abi.encodeWithSelector(ERC20System.proxy.selector));

    token = ERC20Proxy(abi.decode(proxy, (address)));
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
      assertEq("ERC20Test",token.name());
   }

    function testSymbol() external {
      console.log('symbol:', token.symbol());
        assertEq("ERC", token.symbol());
    }


    function testApprove() public {
        token.approve(alice, 1e18);
        assertEq(token.allowance(address(this),alice), 1e18);
    }

    function testIncreaseAllowance() external {
        assertEq(token.allowance(address(this), alice), 0);
        token.increaseAllowance(alice , 2e18);
        assertEq(token.allowance(address(this), alice), 2e18);
    }

    function testDescreaseAllowance() external {
        testApprove();
        token.decreaseAllowance(alice, 0.5e18);
        assertEq(token.allowance(address(this), alice), 0.5e18);
    }


    function testFailApproveToZeroAddress() external {
        token.approve(address(0), 1e18);
    }

//!!!
    function testFailApproveFromZeroAddress() external {
        vm.prank(address(0));
        token.approve(alice, 1e18);
    }


    /* CALLING FROM WORLD */

    // function balance(address account) public returns (uint256 bal) {
    //   bytes memory rawBalance = world.call(
    //     namespace,
    //     ERC20_SYSTEM_NAME,
    //     abi.encodeWithSelector(
    //       ERC20System.balanceOf.selector,
    //      account 
    //     )
    //   );
    //   return abi.decode(rawBalance, (uint256));
    // }

    // function allowance(address owner, address spender) public returns (uint256 bal) {
    //   bytes memory rawBalance = world.call(
    //     namespace,
    //     ERC20_SYSTEM_NAME,
    //     abi.encodeWithSelector(
    //       ERC20System.allowance.selector,
    //       owner, spender
    //     )
    //   );
    //   return abi.decode(rawBalance, (uint256));
    // }

    // function testNameWorld() external {
    //   bytes memory rawName = world.call(
    //     namespace, ERC20_SYSTEM_NAME,
    //     abi.encodeWithSelector(ERC20System.name.selector)
    //   );
    //   string memory name = abi.decode(rawName, (string));
    //   assertEq("GOKU", name);
    // }
    

    // function testSymbolWorld() external {
    // bytes memory rawSymbol = world.call(
    //     namespace, ERC20_SYSTEM_NAME,
    //     abi.encodeWithSelector(ERC20System.symbol.selector)
    //   );
    //   string memory symbol= abi.decode(rawSymbol, (string));
    //     assertEq("GK", symbol);
    // }

    // function testMintWorld() public {
    //   world.call(
    //     namespace,
    //     ERC20_SYSTEM_NAME,
    //     abi.encodeWithSelector(
    //       ERC20TestSystem.mint.selector,
    //       alice,
    //      2e18 
    //     )
    //   );

    //     assertEq(token.totalSupply(), token.balanceOf(alice));
    // }

    // function testBurnWorld() public {
    // world.call(
    //     namespace,
    //     ERC20_SYSTEM_NAME,
    //     abi.encodeWithSelector(
    //       ERC20TestSystem.mint.selector,
    //       alice,
    //      10e18 
    //     )
    //   );

  
    //  assertEq(balance(alice), 10e18);

    //  world.call(
    //     namespace,
    //     ERC20_SYSTEM_NAME,
    //     abi.encodeWithSelector(
    //       ERC20TestSystem.burn.selector,
    //       alice,
    //      8e18 
    //     )
    //   );   

    //   bytes memory totalSupply = world.call(
    //     namespace,
    //     ERC20_SYSTEM_NAME,
    //     abi.encodeWithSelector(
    //       ERC20System.totalSupply.selector
    //     )
    //   );

    //   assertEq(abi.decode(totalSupply, (uint256)), 2e18);

    //  assertEq(balance(alice),2e18);
    // }

    // function testApproveWorld() public {
    //   world.call(
    //     namespace,
    //     ERC20_SYSTEM_NAME,
    //     abi.encodeWithSelector(
    //       ERC20System.approve.selector,
    //       alice,
    //       1e18
    //     )
    //   );

    //     assertEq(allowance(address(this), alice), 1e18);
    // }

    // function testIncreaseAllowanceWorld() external {
    //   world.call(
    //     namespace,
    //     ERC20_SYSTEM_NAME,
    //     abi.encodeWithSelector(
    //       ERC20System.increaseAllowance.selector,
    //       alice,
    //       2e18
    //     )
    //   );

    //     assertEq(allowance(address(this), alice), 2e18);
    // }

    // function testDecreaseAllowanceWorld() external {
    //     testApprove();
    //   world.call(
    //     namespace,
    //     ERC20_SYSTEM_NAME,
    //     abi.encodeWithSelector(
    //       ERC20System.decreaseAllowance.selector,
    //       alice,
    //       0.5e18
    //     )
    //   );

    //     assertEq(allowance(address(this), alice), 0.5e18);
    // }

    // function testTransferWorld() external {
    //     testMintWorld();
    //     vm.startPrank(alice);
    //   world.call(
    //     namespace,
    //     ERC20_SYSTEM_NAME,
    //     abi.encodeWithSelector(
    //       ERC20System.transfer.selector,
    //       bob,
    //       0.5e18
    //     )
    //   );
    //     assertEq(balance(bob), 0.5e18);
    //     assertEq(balance(alice), 1.5e18);
    //     vm.stopPrank();
    // }

    // function testTransferFromWorld() external {
    //     testMintWorld();
    //     vm.prank(alice);
    //   world.call(
    //     namespace,
    //     ERC20_SYSTEM_NAME,
    //     abi.encodeWithSelector(
    //       ERC20System.approve.selector,
    //       address(this),
    //       1e18
    //     )
    //   );
    //   world.call(
    //     namespace,
    //     ERC20_SYSTEM_NAME,
    //     abi.encodeWithSelector(
    //       ERC20System.transferFrom.selector,
    //       alice,
    //       bob,
    //       0.7e18
    //     )
    //   );
    //     assertEq(allowance(alice, address(this)), 1e18 - 0.7e18);
    //     assertEq(balance(alice), 2e18 - 0.7e18);
    //     assertEq(balance( bob), 0.7e18);
    // }

    // /*****************************/
    // /*      Fuzz Testing         */
    // /*****************************/

    // function testFuzzMint(address to, uint256 amount) external {
    //     vm.assume(to != address(0));
    //     token.mint(to,amount);
    //     assertEq(token.totalSupply(), token.balanceOf(to));
    // }

    // function testFuzzBurn(address from, uint256 mintAmount, uint256 burnAmount) external {
    //     vm.assume(from != address(0));              // from address must not zero
    //     burnAmount = bound(burnAmount, 0, mintAmount);    // if burnAmount > mintAmount then bound burnAmount to 0 to mintAmount
    //     token.mint(from , mintAmount);
    //     token.burn(from, burnAmount);
    //     assertEq(token.totalSupply() , mintAmount - burnAmount);
    //     assertEq(token.balanceOf(from), mintAmount - burnAmount);
    // }

    // function testFuzzApprove(address to, uint256 amount) external {
    //     vm.assume(to != address(0));
    //     token.approve(to,amount);
    //     assertEq(token.allowance(address(this),to), amount);
    // }

    // function testFuzzTransfer(address to, uint256 amount) external {
    //     vm.assume(to != address(0));
    //     vm.assume(to != address(this));
    //     token.mint(address(this), amount);
        
    //     token.transfer(to,amount);
    //     assertEq(token.balanceOf(address(this)), 0);
    //     assertEq(token.balanceOf(to), amount);
    // }

    // function testFuzzTransferFrom(address from, address to,uint256 approval, uint256 amount) external {
    //     vm.assume(from != address(0));
    //     vm.assume(to != address(0));

    //     amount = bound(amount, 0, approval);
    //     token.mint(from, amount);

    //     vm.prank(from);
    //     token.approve(address(this), approval);

    //     token.transferFrom(from, to, amount);
    //     assertEq(token.totalSupply(), amount);

    //     if (approval == type(uint256).max){
    //         assertEq(token.allowance(from, address(this)), approval);
    //     }
    //     else {
    //         assertEq(token.allowance(from,address(this)), approval - amount);
    //     }

    //     if (from == to) {
    //         assertEq(token.balanceOf(from), amount);
    //     } else {
    //         assertEq(token.balanceOf(from), 0);
    //         assertEq(token.balanceOf(to), amount);
    //     }
    // }

    // function testFailFuzzBurnInsufficientBalance(address to, uint256 mintAmount, uint256 burnAmount) external {
    //     burnAmount = bound(burnAmount, mintAmount+1, type(uint256).max);

    //     token.mint(to, mintAmount);
    //     token.burn(to, burnAmount);
    // }

    // function testFailTransferInsufficientBalance(address to, uint256 mintAmount, uint256 sendAmount) external {
    //     sendAmount = bound(sendAmount, mintAmount + 1, type(uint256).max);

    //     token.mint(address(this), mintAmount);
    //     token.transfer(to, sendAmount);
    // }

    // function testFailFuzzTransferFromInsufficientApprove(address from, address to,uint256 approval, uint256 amount) external {
    //     amount = bound(amount, approval+1, type(uint256).max);

    //     token.mint(from, amount);
    //     vm.prank(from);
    //     token.approve(address(this), approval);
    //     token.transferFrom(from, to, amount);
    // }

    // function testFailFuzzTransferFromInsufficientBalance(address from, address to, uint256 mintAmount, uint256 sentAmount) external {
    //     sentAmount = bound(sentAmount, mintAmount+1, type(uint256).max);

    //     token.mint(from, mintAmount);
    //     vm.prank(from);
    //     token.approve(address(this), type(uint256).max);

    //     token.transferFrom(from, to, sentAmount);
    // }
}
