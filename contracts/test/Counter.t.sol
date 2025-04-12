// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {AiderToken} from "../src/AiderToken.sol";
import {DeployScript} from "../script/AiderToken.s.sol"; // Optional: For deploying via script helper

contract AiderTokenTest is Test {
    AiderToken public aiderToken;
    address public owner = address(0x1); // Example owner address
    address public user1 = address(0x2); // Example user address
    address public user2 = address(0x3); // Example user address

    uint256 public constant TOKEN_PRICE = 0.1 ether;

    function setUp() public {
        // Deploy the contract, setting 'owner' as the initial owner
        vm.prank(owner);
        aiderToken = new AiderToken(owner);

        // Give users some ETH to test with
        vm.deal(user1, 1 ether);
        vm.deal(user2, 2 ether);
    }

    // --- Test Deployment ---

    function test_Deployment_SetsCorrectOwner() public {
        assertEq(aiderToken.owner(), owner, "Owner should be set correctly");
    }

    function test_Deployment_SetsCorrectName() public {
        assertEq(aiderToken.name(), "AIDER", "Name should be AIDER");
    }

    function test_Deployment_SetsCorrectSymbol() public {
        assertEq(aiderToken.symbol(), "AID", "Symbol should be AID");
    }

    function test_Deployment_SetsCorrectDecimals() public {
        assertEq(aiderToken.decimals(), 18, "Decimals should be 18");
    }

    function test_Deployment_InitialTotalSupplyIsZero() public {
        assertEq(aiderToken.totalSupply(), 0, "Initial total supply should be 0");
    }

    // --- Test buyTokens ---

    function test_BuyTokens_Success_SingleToken() public {
        uint256 initialUserBalance = aiderToken.balanceOf(user1);
        uint256 initialContractEthBalance = address(aiderToken).balance;
        assertEq(initialUserBalance, 0);

        vm.prank(user1);
        aiderToken.buyTokens{value: TOKEN_PRICE}();

        uint256 expectedTokens = 1 * (10**aiderToken.decimals()); // 1 token with 18 decimals
        assertEq(aiderToken.balanceOf(user1), expectedTokens, "User1 should receive 1 token");
        assertEq(address(aiderToken).balance, initialContractEthBalance + TOKEN_PRICE, "Contract ETH balance should increase");
    }

    function test_BuyTokens_Success_MultipleTokens() public {
        uint256 ethToSend = TOKEN_PRICE * 5; // Buy 5 tokens
        uint256 initialUserBalance = aiderToken.balanceOf(user2);
        uint256 initialContractEthBalance = address(aiderToken).balance;
        assertEq(initialUserBalance, 0);

        vm.prank(user2);
        aiderToken.buyTokens{value: ethToSend}();

        uint256 expectedTokens = 5 * (10**aiderToken.decimals()); // 5 tokens with 18 decimals
        assertEq(aiderToken.balanceOf(user2), expectedTokens, "User2 should receive 5 tokens");
        assertEq(address(aiderToken).balance, initialContractEthBalance + ethToSend, "Contract ETH balance should increase by 5 * price");
    }

    function test_RevertWhen_BuyTokens_IncorrectAmount_LessThanPrice() public {
        vm.expectRevert(AiderToken.AiderToken__IncorrectPaymentAmount.selector);
        vm.prank(user1);
        aiderToken.buyTokens{value: TOKEN_PRICE - 1 wei}();
    }

     function test_RevertWhen_BuyTokens_IncorrectAmount_NotMultipleOfPrice() public {
        vm.expectRevert(AiderToken.AiderToken__IncorrectPaymentAmount.selector);
        vm.prank(user1);
        aiderToken.buyTokens{value: TOKEN_PRICE + 1 wei}();
    }

    function test_RevertWhen_BuyTokens_ZeroAmount() public {
        vm.expectRevert(AiderToken.AiderToken__IncorrectPaymentAmount.selector);
        vm.prank(user1);
        aiderToken.buyTokens{value: 0}();
    }

    // --- Test withdraw ---

    function test_Withdraw_Success_ByOwner() public {
        // User1 buys tokens first to fund the contract
        vm.prank(user1);
        aiderToken.buyTokens{value: TOKEN_PRICE}();

        uint256 contractBalanceBefore = address(aiderToken).balance;
        uint256 ownerBalanceBefore = owner.balance;
        assertTrue(contractBalanceBefore > 0);

        // Owner withdraws
        vm.prank(owner);
        aiderToken.withdraw();

        assertEq(address(aiderToken).balance, 0, "Contract ETH balance should be 0 after withdrawal");
        // Owner's balance increases by the contract balance (minus gas costs, difficult to assert exactly without gas calculations)
        assertTrue(owner.balance > ownerBalanceBefore, "Owner ETH balance should increase after withdrawal");
    }

    function test_RevertWhen_Withdraw_ByNonOwner() public {
        // User1 buys tokens first to fund the contract
        vm.prank(user1);
        aiderToken.buyTokens{value: TOKEN_PRICE}();

        // Non-owner attempts to withdraw
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(user2); // Attempt withdrawal as user2
        aiderToken.withdraw();
    }

     function test_Withdraw_WhenBalanceIsZero() public {
        uint256 contractBalanceBefore = address(aiderToken).balance;
        uint256 ownerBalanceBefore = owner.balance;
        assertEq(contractBalanceBefore, 0);

        // Owner withdraws (should succeed even with 0 balance)
        vm.prank(owner);
        aiderToken.withdraw();

        assertEq(address(aiderToken).balance, 0, "Contract ETH balance should remain 0");
        // Owner's balance might decrease slightly due to gas
        assertTrue(owner.balance <= ownerBalanceBefore, "Owner ETH balance should not increase");
    }
}
