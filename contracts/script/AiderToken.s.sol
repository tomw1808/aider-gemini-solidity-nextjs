// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {AiderToken} from "../src/AiderToken.sol";

contract DeployScript is Script {
    AiderToken public aiderToken;

    function run() external returns (AiderToken) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        // Pass the deployer's address as the initial owner
        aiderToken = new AiderToken(deployerAddress);

        vm.stopBroadcast();
        console2.log("AiderToken deployed at:", address(aiderToken));
        console2.log("Owner:", aiderToken.owner());
        return aiderToken;
    }
}
