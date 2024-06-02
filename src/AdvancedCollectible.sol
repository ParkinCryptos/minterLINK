// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract AdvancedCollectible is VRFConsumerBaseV2Plus, ERC721URIStorage {
    uint256 public tokenCounter;

    enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERNARD
    }

    // add other things
    mapping(uint256 => address) public requestIdToSender;
    mapping(uint256 => string) public requestIdToTokenURI;
    mapping(uint256 => Breed) public tokenIdToBreed;
    mapping(uint256 => uint256) public requestIdToTokenId;

    event RequestedCollectible(uint256 indexed requestId);
    // New event from the video!
    event ReturnedCollectible(uint256 indexed newItemId, Breed breed);

    bytes32 internal keyHash;
    uint256 subscriptionId;
    IVRFCoordinatorV2Plus COORDINATOR;

    constructor(
        address _VRFCoordinator,
        uint256 _subscriptionId,
        bytes32 _keyhash
    ) VRFConsumerBaseV2Plus(_VRFCoordinator) ERC721("Doggie", "DOG") {
        tokenCounter = 0;
        keyHash = _keyhash;
        COORDINATOR = IVRFCoordinatorV2Plus(_VRFCoordinator);
        subscriptionId = _subscriptionId;
    }

    function createCollectible(
        string memory tokenURI // returns (uint256)
    ) public {
        uint256 requestId = COORDINATOR.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: subscriptionId,
                requestConfirmations: 1,
                callbackGasLimit: 1000000,
                numWords: 3,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
        requestIdToSender[requestId] = msg.sender;
        requestIdToTokenURI[requestId] = tokenURI;
        emit RequestedCollectible(requestId);
    }

    function fulfillRandomWords(
        uint256 requestId,
        // uint256 calldata randomWords
        uint256[] memory randomWords
    ) internal override {
        address dogOwner = requestIdToSender[requestId];
        string memory tokenURI = requestIdToTokenURI[requestId];
        uint256 newItemId = tokenCounter;
        _safeMint(dogOwner, newItemId);
        _setTokenURI(newItemId, tokenURI);
        Breed breed = Breed(randomWords[0] % 3);
        tokenIdToBreed[newItemId] = breed;
        requestIdToTokenId[requestId] = newItemId;
        tokenCounter = tokenCounter + 1;
        emit ReturnedCollectible(newItemId, breed);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        require(
            ownerOf(tokenId) == _msgSender() ||
                getApproved(tokenId) == _msgSender(),
            "ERC721: transfer caller is not owner nor approved"
        );
        _setTokenURI(tokenId, _tokenURI);
    }
}
