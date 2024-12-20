// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";
import {VRFCoordinatorV2_5Mock} "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2_5Mock.sol";


abstract contract CodeConstants {
    // VRF Mock Values
    uint96 MOCK_BASE_FEE = 0.25 ether;
    uint96 public MOCK_GAS_PRICE_LINK = 1e9;
    // LINK / ETH price:
    int256 public MOCK_WEI_PER_UINT_LINK = 4E15;


    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 1115511;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfig is CodeConstants, Script {
    //errors:
    error HelperConfig_InvalidChainId();

    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint32 callbackGasLimit;
        uint256 subscriptionId;
    }

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
    }

    function getConfigByChainId(
        uint256 chainId
    ) public view returns (NetworkConfig memory) {
        if (networkConfigs[chainId].vrfCoordinator != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert HelperConfig_InvalidChainId();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether, // 1e16
                interval: 30,
                vrfCoordinator: 0xD7f86b4b8Cae7D942340FF628F82735b7a20893a,
                gasLane: 0x8077df514608a09f83e4e8d300645594e5d7234665448ba83f51a50f842bd3d9,
                callbackGasLimit: 500000,
                subscriptionId: 0
            });
    }

    function getOrCreateAnvilEthConfig() public view returns (NetworkConfig memory){
        if(localNetworkConfig.vrfCoordinator != address(0)){
            return localNetworkConfig;
        }else{
            revert HelperConfig_InvalidChainId();
        }

        // Deploy mocks and such:
        vm.startBroadcast();
        VRRVRFCoordinatorV2_5Mock vrfCoordinatorMock = new VRRVRFCoordinatorV2_5Mock(MOCK_BASE_FEE,MOCK_GAS_PRICE_LINK,MOCK_WEI_PER_UINT_LINK);
        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({
            entranceFee: 0.01 ether, // 1e16
                interval: 30,
                vrfCoordinator: address(vrfCoordinatorMock),
                gasLane: 0x8077df514608a09f83e4e8d300645594e5d7234665448ba83f51a50f842bd3d9,
                callbackGasLimit: 500000,
                subscriptionId: 0
        });
        return localNetworkConfig;
    }
}
