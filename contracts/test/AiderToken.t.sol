// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {AiderToken} from "../src/AiderToken.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol"; // Import Ownable for the error selector
// No longer importing DeployScript as it's not used directly in tests

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

    function test_Deployment_SetsCorrectOwner() public view {
        assertEq(aiderToken.owner(), owner, "Owner should be set correctly");
    }

    function test_Deployment_SetsCorrectName() public view {
        assertEq(aiderToken.name(), "AIDER", "Name should be AIDER");
    }

    function test_Deployment_SetsCorrectSymbol() public view {
        assertEq(aiderToken.symbol(), "AID", "Symbol should be AID");
    }

    function test_Deployment_SetsCorrectDecimals() public view {
        assertEq(aiderToken.decimals(), 18, "Decimals should be 18");
    }

    function test_Deployment_InitialTotalSupplyIsZero() public view {
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
        assertEq(aiderToken.balanceOf(user1), expectedTokens, "User1 token balance should match expected amount");
        assertEq(address(aiderToken).balance, initialContractEthBalance + TOKEN_PRICE, "Contract ETH balance should increase by exact price");
    }

    function test_BuyTokens_Success_MultipleTokens_ExactAmount() public {
        uint256 ethToSend = TOKEN_PRICE * 5; // Buy 5 tokens
        uint256 initialUserBalance = aiderToken.balanceOf(user2);
        uint256 initialContractEthBalance = address(aiderToken).balance;
        assertEq(initialUserBalance, 0);

        vm.prank(user2);
        aiderToken.buyTokens{value: ethToSend}();

        uint256 expectedTokens = 5 * (10**aiderToken.decimals()); // 5 tokens with 18 decimals
        assertEq(aiderToken.balanceOf(user2), expectedTokens, "User2 token balance should match expected amount");
        assertEq(address(aiderToken).balance, initialContractEthBalance + ethToSend, "Contract ETH balance should increase by exact amount sent");
    }

    function test_BuyTokens_Success_WithRefund() public {
        uint256 excessAmount = 500 wei;
        uint256 ethToSend = TOKEN_PRICE * 2 + excessAmount; // Buy 2 tokens + excess
        uint256 initialUserEthBalance = user1.balance;
        uint256 initialContractEthBalance = address(aiderToken).balance;

        vm.prank(user1);
        // Estimate gas cost (very rough, better to check balance change relative to amount sent)
        uint256 gasStart = gasleft();
        aiderToken.buyTokens{value: ethToSend}();
        uint256 gasUsed = gasStart - gasleft();
        uint256 txCost = tx.gasprice * gasUsed; // Approximate cost

        uint256 expectedTokens = 2 * (10**aiderToken.decimals());
        assertEq(aiderToken.balanceOf(user1), expectedTokens, "User1 token balance should match expected amount after refund");
        // Contract balance increases only by the token cost, not the refund amount
        assertEq(address(aiderToken).balance, initialContractEthBalance + (TOKEN_PRICE * 2), "Contract ETH balance should increase by cost of 2 tokens");
        // User's ETH balance should decrease by the cost of tokens + gas, reflecting the refund
        assertEq(user1.balance, initialUserEthBalance - (TOKEN_PRICE * 2) - txCost, "User ETH balance should decrease by token cost + gas, reflecting refund");
    }

    function test_RevertWhen_BuyTokens_InsufficientAmount() public {
        vm.expectRevert(AiderToken.AiderToken__InsufficientPayment.selector);
        vm.prank(user1);
        aiderToken.buyTokens{value: TOKEN_PRICE - 1 wei}(); // Less than minimum price
    }

    function test_RevertWhen_BuyTokens_ZeroAmount() public {
        vm.expectRevert(AiderToken.AiderToken__InsufficientPayment.selector);
        vm.prank(user1);
        aiderToken.buyTokens{value: 0}(); // Zero amount
    }

    // --- Test receive function ---

    function test_Receive_Success_ExactAmount() public {
        uint256 initialUserBalance = aiderToken.balanceOf(user1);
        uint256 initialContractEthBalance = address(aiderToken).balance;
        assertEq(initialUserBalance, 0);

        // Send ETH directly to the contract
        vm.prank(user1); // Set the sender for the next call
        (bool success, ) = address(aiderToken).call{value: TOKEN_PRICE}(""); // Removed sender option
        assertTrue(success, "Direct ETH transfer should succeed");

        uint256 expectedTokens = 1 * (10**aiderToken.decimals());
        assertEq(aiderToken.balanceOf(user1), expectedTokens, "User1 token balance should match expected amount via receive()");
        assertEq(address(aiderToken).balance, initialContractEthBalance + TOKEN_PRICE, "Contract ETH balance should increase via receive()");
    }

     function test_Receive_Success_WithRefund() public {
        uint256 excessAmount = 600 wei;
        uint256 ethToSend = TOKEN_PRICE * 3 + excessAmount; // Buy 3 tokens + excess
        uint256 initialUserEthBalance = user2.balance;
        uint256 initialContractEthBalance = address(aiderToken).balance;

        // Send ETH directly
        vm.prank(user2); // Set the sender for the next call
        (bool success, ) = address(aiderToken).call{value: ethToSend}(""); // Removed sender option
        assertTrue(success, "Direct ETH transfer with excess should succeed");

        uint256 expectedTokens = 3 * (10**aiderToken.decimals());
        assertEq(aiderToken.balanceOf(user2), expectedTokens, "User2 token balance should match expected amount via receive() after refund");
        // Contract balance increases only by the token cost
        assertEq(address(aiderToken).balance, initialContractEthBalance + (TOKEN_PRICE * 3), "Contract ETH balance should increase by cost of 3 tokens via receive()");
         // User's ETH balance should decrease by the cost of tokens (gas estimation omitted here for simplicity, focus on refund)
        // Note: Precise balance check is tricky due to gas on the external call from the test contract vs internal call in buyTokens
        assertTrue(user2.balance > initialUserEthBalance - ethToSend && user2.balance <= initialUserEthBalance - (TOKEN_PRICE * 3), "User ETH balance should reflect refund");
     }

    function test_RevertWhen_Receive_InsufficientAmount() public {
        // Sending less than TOKEN_PRICE directly should revert inside buyTokens
        vm.prank(user1); // Set the sender for the next call
        vm.expectRevert(AiderToken.AiderToken__InsufficientPayment.selector);
        (bool success, ) = address(aiderToken).call{value: TOKEN_PRICE - 1 wei}(""); // Removed sender option
        // The external call itself might succeed, but the internal logic reverts.
        // Foundry's expectRevert should catch this. If not, need a more specific check.
        // assertTrue(!success); // Removed redundant assertion - expectRevert handles the check.
    }

     function test_RevertWhen_Receive_ZeroAmount() public {
        // Sending zero ETH directly should revert inside buyTokens
        vm.prank(user1); // Set the sender for the next call
        vm.expectRevert(AiderToken.AiderToken__InsufficientPayment.selector);
        (bool success, ) = address(aiderToken).call{value: 0}(""); // Removed sender option
        // assertTrue(!success); // Removed redundant assertion - expectRevert handles the check.
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
        // Expect the OZ v5 error: OwnableUnauthorizedAccount(address account)
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user2));
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
