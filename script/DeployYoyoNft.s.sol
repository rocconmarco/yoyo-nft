// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {YoyoNft} from "../src/YoyoNft.sol";

contract DeployYoyoNft is Script {
    
    function run() external returns (YoyoNft) {
        address vrfCoordinator = vm.envAddress("VRF_COORDINATOR");
        bytes32 keyHash = vm.envBytes32("KEY_HASH");
        uint256 subscriptionId = vm.envUint("SUBSCRIPTION_ID");
        uint32 callbackGasLimit = 200_000;
        string memory baseUri = vm.envString("BASE_URI");

        vm.startBroadcast();
        YoyoNft yoyoNft = new YoyoNft(vrfCoordinator, keyHash, subscriptionId, callbackGasLimit, baseUri);
        vm.stopBroadcast();
        return yoyoNft;
    }
}