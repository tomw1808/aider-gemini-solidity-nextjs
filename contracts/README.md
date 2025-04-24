# Aider Token (AID) - Smart Contract

This directory contains the Solidity smart contract (`AiderToken.sol`), tests, and deployment scripts for the Aider test project. This contract was developed using the Foundry framework and OpenZeppelin Contracts v5, largely guided by prompts given to Aider.

Refer to the main project [README.md](../README.md) for the overall project context.

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

## Setup (Inside `contracts` directory)

1.  **Install Foundry:** Follow the instructions at https://book.getfoundry.sh/getting-started/installation
2.  **Clone the repository:**
    ```shell
    git clone <your-repo-url>
    cd contracts # Make sure you are in the contracts directory
    ```
3.  **Install dependencies (OpenZeppelin):**
    ```shell
    forge install OpenZeppelin/openzeppelin-contracts@v5.0.2 --no-commit
    forge install foundry-rs/forge-std --no-commit # If not already present
    ```
    *(You might need to run `git submodule update --init --recursive` if `forge install` doesn't pull submodules)*

## Usage (Inside `contracts` directory)

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

Start a local blockchain node in a separate terminal:
```shell
anvil
```
Anvil will typically start on `http://127.0.0.1:8545`. It will also list available accounts and their private keys, which you can import into MetaMask.

**Connecting MetaMask to Anvil:**
1. Open MetaMask and click on the network dropdown.
2. Select "Add network" or "Custom RPC".
3. Enter the following details:
    * Network Name: Anvil Local
    * New RPC URL: `http://127.0.0.1:8545`
    * Chain ID: `31337`
    * Currency Symbol: ETH
4. Save the network.
5. Import an Anvil account using one of the private keys logged by the `anvil` command.

### Deploy Locally to Anvil

Deploy the `AiderToken` contract to your running Anvil instance:

**Prerequisites:**

*   Ensure Anvil is running.
*   Set the `PRIVATE_KEY` environment variable to one of the private keys provided by Anvil when it started. You can do this temporarily in your terminal:
    ```shell
    export PRIVATE_KEY=<anvil_private_key>
    ```

**Deployment Command:**

```shell
forge script script/AiderToken.s.sol:DeployScript --rpc-url http://127.0.0.1:8545 --private-key $PRIVATE_KEY --broadcast
```

*   `--broadcast`: Sends the transaction to the local Anvil network.
*   The script will output the deployed contract address. **Copy this address.** You will need it for the frontend configuration (`app/page.tsx`).
