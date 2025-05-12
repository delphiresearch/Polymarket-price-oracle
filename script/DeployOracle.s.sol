// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {PolymarketPriceOracle} from "../src/PolymarketPriceOracle.sol";
import {Order,OrderStatus,Side,SignatureType} from "../src/libs/PolymarketOrderStruct.sol";
import {ICTFExchange} from "../src/interfaces/ICTFExchange.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract DeployOracle is Script {

    function run() public {
        vm.startBroadcast();
        // NegRiskCtfExchange
        // https://polygonscan.com/address/0xc5d563a36ae78145c45a50134d48a1215220f80a
        address polymarketExchange = 0xC5d563A36AE78145C45a50134d48A1215220f80a;
        uint256 ttl = 2 minutes;
        uint256 oned = 10**6;
        new PolymarketPriceOracle(polymarketExchange, ttl, 5*oned);
        console.log("PolymarketPriceOracle deployed");
        vm.stopBroadcast();
    }

    function usecase() public {
        vm.startBroadcast();
        PolymarketPriceOracle oracle = PolymarketPriceOracle(0xC5d563A36AE78145C45a50134d48A1215220f80a);
        uint256 price = oracle.getPrice(42724236397250207575427650023998452742043727100438655051778673245427936844254).price;
        console.log("price", price);
        vm.stopBroadcast();
    }
}
