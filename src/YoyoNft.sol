// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract YoyoNft is ERC721, VRFConsumerBaseV2Plus {
    error YoyoNft__AllNFTsHaveBeenMinted();
    error YoyoNft__TokenIdDoesNotExist();
    error YoyoNft__NoAvailableTokenIDs();

    using VRFV2PlusClient for VRFV2PlusClient.RandomWordsRequest;

    IVRFCoordinatorV2Plus private immutable i_vrfCoordinator;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATION = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private s_tokenCounter;
    uint256 private constant MAX_NFT_SUPPLY = 125;
    uint256 private constant MIN_TOKEN_ID = 1;
    string private s_baseURI;

    mapping(uint256 => address) private s_requestIdToSender;
    mapping(uint256 => bool) private s_tokenIdMinted;

    event NftRequested(uint256 indexed requestId, address requester);
    event NftMinted(uint256 indexed tokenId, address minter);

    constructor(
        address vrfCoordinator,
        bytes32 keyHash,
        uint256 subscriptionId,
        uint32 callbackGasLimit,
        string memory baseURI
    ) ERC721("YoyoNft", "YOYO") VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_vrfCoordinator = IVRFCoordinatorV2Plus(vrfCoordinator);
        i_keyHash = keyHash;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;

        s_tokenCounter = 0;
        s_baseURI = baseURI;
    }

    function requestNft() public {
        if (s_tokenCounter >= MAX_NFT_SUPPLY) {
            revert YoyoNft__AllNFTsHaveBeenMinted();
        }

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: REQUEST_CONFIRMATION,
            callbackGasLimit: i_callbackGasLimit,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
        });

        uint256 requestId = i_vrfCoordinator.requestRandomWords(request);
        s_requestIdToSender[requestId] = msg.sender;

        emit NftRequested(requestId, msg.sender);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        address nftOwner = s_requestIdToSender[requestId];

        uint256 moddedRng = (randomWords[0] % MAX_NFT_SUPPLY) + MIN_TOKEN_ID;
        uint256 tokenId = findAvailableTokenId(moddedRng);

        s_tokenIdMinted[tokenId] = true;
        s_tokenCounter++;

        _safeMint(nftOwner, tokenId);

        emit NftMinted(tokenId, nftOwner);
    }

    function findAvailableTokenId(uint256 startingIndex) private view returns (uint256) {
        uint256 tokenId = startingIndex;
        for (uint256 i = 0; i < MAX_NFT_SUPPLY; i++) {
            if (!s_tokenIdMinted[tokenId]) {
                return tokenId;
            }
            tokenId = (tokenId % MAX_NFT_SUPPLY) + MIN_TOKEN_ID;
            if (tokenId == 0) tokenId = MIN_TOKEN_ID;
        }
        revert YoyoNft__NoAvailableTokenIDs();
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (tokenId == 0 || tokenId > 125) {
            revert YoyoNft__TokenIdDoesNotExist();
        }
        return string(abi.encodePacked(s_baseURI, "/", Strings.toString(tokenId), ".json"));
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        s_baseURI = baseURI;
    }

    function getSenderForRequestId(uint256 requestId) public view returns (address) {
        return s_requestIdToSender[requestId];
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
