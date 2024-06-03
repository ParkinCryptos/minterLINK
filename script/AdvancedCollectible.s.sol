// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {AdvancedCollectible} from "../src/AdvancedCollectible.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        AdvancedCollectible nft = new AdvancedCollectible(
            0x343300b5d84D444B2ADc9116FEF1bED02BE49Cf2,
            84884834156683469445878453683374503348282528287859345644082046707853162354782,
            0x816bedba8a50b294e5cbd47842baf240c2385f2eaf719edbd4f250a137a8c899
        );
        vm.stopBroadcast();
    }
}
