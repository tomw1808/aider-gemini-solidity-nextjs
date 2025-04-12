# Aider Token (AID)

This project implements a standard ERC20 token named "AIDER" with the symbol "AID" and 18 decimals, built using the Foundry framework and OpenZeppelin Contracts v5.

## Features

*   **ERC20 Standard:** Compliant with the ERC20 token standard.
*   **Token Sale:** Users can purchase AIDER tokens directly from the contract by sending ETH.
    *   **Price:** 1 AID = 0.1 ETH
*   **Ownable:** The contract includes ownership management using OpenZeppelin's `Ownable`, allowing the owner to withdraw collected ETH.
*   **No Initial Supply:** Tokens are minted only when purchased.

## Development Environment

This project uses Foundry for development, testing, and deployment.

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

*   **Foundry Book:** https://book.getfoundry.sh/
*   **OpenZeppelin Contracts:** https://docs.openzeppelin.com/contracts/5.x/

## Setup

1.  **Install Foundry:** Follow the instructions at https://book.getfoundry.sh/getting-started/installation
2.  **Clone the repository:**
    ```shell
    git clone <your-repo-url>
    cd <your-repo-directory>
    ```
3.  **Install dependencies (OpenZeppelin):**
    ```shell
    forge install
    ```
    *(If you haven't already run `forge install OpenZeppelin/openzeppelin-contracts@v5.0.2 --no-commit`)*

## Usage

### Build

Compile the smart contracts:
```shell
forge build
```

### Test

Run the test suite:
```shell
forge test
```

### Format

Format the Solidity code:
```shell
forge fmt
```

### Gas Snapshots

Generate gas snapshots for the tests:
```shell
forge snapshot
```

### Local Development Node (Anvil)

Start a local blockchain node:
```shell
anvil
```

### Deploy to Base Sepolia

Deploy the `AiderToken` contract to the Base Sepolia test network:

**Prerequisites:**

*   Set your Base Sepolia RPC URL as an environment variable: `export RPC_URL=<your_base_sepolia_rpc_url>`
*   Set your deployer wallet's private key as an environment variable: `export PRIVATE_KEY=<your_private_key>` (Ensure this key is funded with Base Sepolia ETH).

**Deployment Command:**

```shell
forge script script/AiderToken.s.sol:DeployScript --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify -vvvv
```

*   `--broadcast`: Sends the transaction to the network.
*   `--verify`: Attempts to verify the contract source code on the block explorer (e.g., Basescan Sepolia). Requires setting `ETHERSCAN_API_KEY` for Base Sepolia.
*   `-vvvv`: Increases verbosity for detailed output.

### Interacting with the Contract (Cast)

Use `cast` to interact with the deployed contract. Examples:

*   **Check Token Name:** `cast call <CONTRACT_ADDRESS> "name()(string)" --rpc-url $RPC_URL`
*   **Buy Tokens (Example: Buy 2 AID):** `cast send <CONTRACT_ADDRESS> "buyTokens()" --value 0.2ether --rpc-url $RPC_URL --private-key <your_user_private_key>`
*   **Check Balance:** `cast call <CONTRACT_ADDRESS> "balanceOf(address)(uint256)" <YOUR_ADDRESS> --rpc-url $RPC_URL`
*   **Withdraw ETH (as owner):** `cast send <CONTRACT_ADDRESS> "withdraw()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY`

### Help

```shell
forge --help
anvil --help
cast --help
```
