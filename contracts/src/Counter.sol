// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts v5.0.2
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract AiderToken is ERC20, Ownable {
    uint256 public constant TOKEN_PRICE = 0.1 ether; // Price per token in ETH (wei)

    error AiderToken__IncorrectPaymentAmount();
    error AiderToken__TransferFailed();

    constructor(address initialOwner) ERC20("AIDER", "AID") Ownable(initialOwner) {
        // No initial supply is minted upon deployment in this version.
        // Tokens are only created when purchased via buyTokens.
    }

    /**
     * @notice Allows users to buy tokens by sending ETH.
     * @dev Mints new tokens to the sender based on the ETH sent and the TOKEN_PRICE.
     *      Requires msg.value to be a multiple of TOKEN_PRICE.
     */
    function buyTokens() external payable {
        if (msg.value == 0 || msg.value % TOKEN_PRICE != 0) {
            revert AiderToken__IncorrectPaymentAmount();
        }

        uint256 tokensToMint = msg.value / TOKEN_PRICE;
        _mint(msg.sender, tokensToMint);
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
