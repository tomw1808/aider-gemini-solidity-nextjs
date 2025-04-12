// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts v5.0.2
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract AiderToken is ERC20, Ownable {
    uint256 public constant TOKEN_PRICE = 0.1 ether; // Price per token in ETH (wei)

    error AiderToken__InsufficientPayment();
    error AiderToken__TransferFailed();

    constructor(address initialOwner) ERC20("AIDER", "AID") Ownable(initialOwner) {
        // No initial supply is minted upon deployment in this version.
        // Tokens are only created when purchased via buyTokens.
    }

    /**
     * @notice Allows users to buy tokens by sending ETH.
     * @dev Mints new tokens to the sender based on the ETH sent and the TOKEN_PRICE.
     *      Requires msg.value to be at least TOKEN_PRICE.
     *      Refunds any ETH sent in excess of the cost of whole tokens.
     */
    function buyTokens() public payable { // Changed from external to public
        if (msg.value < TOKEN_PRICE) {
            revert AiderToken__InsufficientPayment();
        }

        uint256 tokensToMint = msg.value / TOKEN_PRICE; // Number of tokens (e.g., 5)
        uint256 amountToMint = tokensToMint * (10**decimals()); // Amount in base units (e.g., 5 * 10**18)
        uint256 refundAmount = msg.value % TOKEN_PRICE;

        _mint(msg.sender, amountToMint); // Mint the correct amount in base units

        // Refund excess ETH if any
        if (refundAmount > 0) {
            (bool success, ) = msg.sender.call{value: refundAmount}("");
            if (!success) {
                revert AiderToken__TransferFailed();
                // Note: In a real-world scenario, consider the implications
                // if the refund fails (e.g., user contract cannot receive ETH).
                // The tokens are already minted at this point.
            }
        }
    }

    /**
     * @notice Allows direct ETH transfers to the contract to buy tokens.
     * @dev Calls the buyTokens function internally.
     */
    receive() external payable {
        buyTokens();
    }

    /**
     * @notice Allows the owner to withdraw the accumulated ETH balance from the contract.
     */
    function withdraw() external onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");
        if (!success) {
            revert AiderToken__TransferFailed();
        }
    }

    // The decimals function is inherited from ERC20 and defaults to 18.
}
