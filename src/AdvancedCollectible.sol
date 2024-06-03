// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract AdvancedCollectible is VRFConsumerBaseV2Plus, ERC721URIStorage {
    uint256 public tokenCounter;

    string[] public breeds = [
        "PUG",
        "SHIBA_INU",
        "ST_BERNARD",
        "CHIHUAHUA",
        "POMERANIAN"
    ];

    /* enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERNARD,
        CHIHUAHUA,
        POMERANIAN
    }
*/
    // add other things
    mapping(uint256 => address) public requestIdToSender;
    // mapping(uint256 => string) public requestIdToTokenURI;
    mapping(uint256 => string) public tokenIdToBreed;
    // mapping(uint256 => uint256) public requestIdToTokenId;
    mapping(string => string) public breedToUri;

    event RequestedCollectible(uint256 indexed requestId);
    // New event from the video!
    event ReturnedCollectible(uint256 indexed newItemId, string breed);

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

        // Hardcode the URIs here
        breedToUri[
            "PUG"
        ] = "ipfs://QmWP2tJQzU2demmNjdETBrBKTSm3B9iqqQsGXmMykvuvne";
        breedToUri[
            "SHIBA_INU"
        ] = "ipfs://QmZNZTUNg7gzkRphw8KafZcPyEJnDAQr18GuSYaCbbYbvX";
        breedToUri[
            "ST_BERNARD"
        ] = "ipfs://QmXJpa3cfUP7PHN4AU5onhYULkM1Y9ipYqMkYD6Hx7Hr41";
        breedToUri[
            "CHIHUAHUA"
        ] = "ipfs://QmZsMt5jmuLXKebcAM5TQmWjYf4CmttooVQYwSc49j3WDm";
        breedToUri[
            "POMERANIAN"
        ] = "ipfs://QmfGHuQ9xDR2neE2EYdsBnxQrUNV6wtaXg6nUkeS2kC53W";
    }

    function createCollectible()
        public
    // string memory tokenURI // returns (uint256)
    {
        uint256 requestId = COORDINATOR.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: subscriptionId,
                requestConfirmations: 3,
                callbackGasLimit: 1000000,
                numWords: 1,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
        requestIdToSender[requestId] = msg.sender;
        emit RequestedCollectible(requestId);
    }

    function fulfillRandomWords(
        uint256 requestId,
        // uint256 calldata randomWords
        uint256[] memory randomWords
    ) internal override {
        address dogOwner = requestIdToSender[requestId];
        // string memory tokenURI = requestIdToTokenURI[requestId];
        string memory breed = breeds[randomWords[0] % breeds.length];
        uint256 newItemId = tokenCounter;
        _safeMint(dogOwner, newItemId);
        _setTokenURI(newItemId, breedToUri[breed]);
        tokenIdToBreed[newItemId] = breed;
        // requestIdToTokenId[requestId] = newItemId;
        tokenCounter = tokenCounter + 1;
        emit ReturnedCollectible(newItemId, breed);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        string memory base = "data:application/json;base64,";
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        tokenIdToBreed[tokenId],
                        '",',
                        '"description": "A randomly generated dog breed.",',
                        '"image": "',
                        breedToUri[tokenIdToBreed[tokenId]],
                        '"}'
                    )
                )
            )
        );
        return string(abi.encodePacked(base, json));
    }

    /*
    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        require(
            ownerOf(tokenId) == _msgSender() ||
                getApproved(tokenId) == _msgSender(),
            "ERC721: transfer caller is not owner nor approved"
        );
        _setTokenURI(tokenId, _tokenURI);
    }
    */
}
