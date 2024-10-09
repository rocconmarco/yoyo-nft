// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {YoyoNft} from "../src/YoyoNft.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract YoyoNftTest is Test {
    YoyoNft public yoyoNft;
    VRFCoordinatorV2_5Mock public vrfCoordinator;

    bytes32 private constant KEY_HASH = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    uint32 private constant CALLBACK_GAS_LIMIT = 200_000;
    string private constant BASE_URI = "ipfs://bafybeibdhnlz3e7nix7uufgwnjvogkzwobgotaolshyw6hcnmpbrdh54za";

    address public constant USER = address(1);
    uint96 public constant FUND_AMOUNT = 30000000000000000000;

    event NftRequested(uint256 indexed requestId, address requester);
    event NftMinted(uint256 indexed tokenId, address minter);

    function setUp() public {
        vrfCoordinator = new VRFCoordinatorV2_5Mock(100000000000000000, 1000000000, 4639000000000000);

        vm.startPrank(USER);
        uint256 subId = vrfCoordinator.createSubscription();
        vrfCoordinator.fundSubscription(subId, FUND_AMOUNT);

        yoyoNft = new YoyoNft(address(vrfCoordinator), KEY_HASH, subId, CALLBACK_GAS_LIMIT, BASE_URI);

        vrfCoordinator.addConsumer(subId, address(yoyoNft));
        vm.stopPrank();
    }

    function testYoyoNftName() public view {
        assertEq(yoyoNft.name(), "YoyoNft");
    }

    function testYoyoNftSymbol() public view {
        assertEq(yoyoNft.symbol(), "YOYO");
    }

    function testRequestNft() public {
        vm.expectEmit(true, false, false, true);
        emit NftRequested(1, USER);

        vm.prank(USER);
        yoyoNft.requestNft();

        assertEq(yoyoNft.getSenderForRequestId(1), USER);

        uint256[] memory randomWords = new uint256[](1);
        randomWords[0] = 777;

        uint256 tokenId = (randomWords[0] % 125) + 1;

        vm.expectEmit(true, false, false, true);
        emit NftMinted(tokenId, USER);

        vrfCoordinator.fulfillRandomWordsWithOverride(1, address(yoyoNft), randomWords);
    }
}
