// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
// forge 
import {Test, console} from "forge-std/Test.sol";
import {PolymarketPriceOracle} from "../src/PolymarketPriceOracle.sol";
import {ICTFExchange} from "../src/interfaces/ICTFExchange.sol";
import {Order, Side, SignatureType, OrderStatus} from "../src/libs/PolymarketOrderStruct.sol";

contract MockICTFExchange {
    ICTFExchange public ctfExchange;
    constructor(address _ctfExchange) {
        ctfExchange = ICTFExchange(_ctfExchange);
    }
    mapping(bytes32 => OrderStatus) internal _orderStatus;
    
    //MOCK ONLY
    function orderStatus(bytes32 orderHash) external view returns (OrderStatus memory) {
        return _orderStatus[orderHash];
    }
    function hashOrder(Order calldata order) external view returns (bytes32) {
        return ctfExchange.hashOrder(order);
    }
    function registry(uint256 tokenId) external view returns (uint256 complement, bytes32 conditionId) {
        return ctfExchange.registry(tokenId);
    }
    //MOCK ONLY
    function _setOrderStatus(Order calldata order, OrderStatus memory newStatus) external {
        _orderStatus[ctfExchange.hashOrder(order)] = newStatus;
    }
    function getComplement(uint256 tokenId) external view returns (uint256) {
        return ctfExchange.getComplement(tokenId);
    }
    function getConditionId(uint256 tokenId) external view returns (bytes32) {
        return ctfExchange.getConditionId(tokenId);
    }
}

contract PolymarketPriceOracleBeforeFilledTest is Test {
    PolymarketPriceOracle public polymarketPriceOracle;
    MockICTFExchange public polymarket;
    ICTFExchange public polymarketReal;
    address public NEG_RIST_EX = 0xC5d563A36AE78145C45a50134d48A1215220f80a;
    uint256 MIN_USDC_NOTIONAL = 10 ** 6; //1 USDC
    uint256 ONE = 10 ** 18;


    Order public baseOrder = Order({
        salt: 1436683769915,
        maker: 0x1aA44c933A6718a4BC44064F0067A853c34be9B0,
        signer: 0x1aA44c933A6718a4BC44064F0067A853c34be9B0,
        taker: 0x0000000000000000000000000000000000000000,
        tokenId: 42724236397250207575427650023998452742043727100438655051778673245427936844254,
        makerAmount: 3997600,
        takerAmount: 5260000,
        expiration: 0,
        nonce: 0,
        feeRateBps: 0,
        side: Side.BUY,
        signatureType: SignatureType.EOA,
        signature: "0xeb0f6e7244e72b3b07b85b1524320758ecb8991...7fcfcbae0dff1ad439d518eab07907d33c56cf8f3ad65b3db828b6c639a4f1b"
    });

    Order public subOrder = Order({
        salt: 1436683769914,
        maker: 0x1aA44c933A6718a4BC44064F0067A853c34be9B0,
        signer: 0x1aA44c933A6718a4BC44064F0067A853c34be9B0,
        taker: 0x0000000000000000000000000000000000000000,
        tokenId: 86337476411225396782940416611040694123774553224828196996839974817619931765236,
        makerAmount: 52600000,
        takerAmount: 39976000,
        expiration: 0,
        nonce: 0,
        feeRateBps: 0,
        side: Side.SELL,
        signatureType: SignatureType.EOA,
        signature: "0xeb0f6e7244e72b3b07b85b1524320758ecb8991...7fcfcbae0dff1ad439d518eab07907d33c56cf8f3ad65b3db828b6c639a4f1b"
    });

    function setUp() public {
        polymarketReal = ICTFExchange(NEG_RIST_EX);
        polymarket = new MockICTFExchange(address(polymarketReal));
        polymarketPriceOracle = new PolymarketPriceOracle(address(polymarket), 1 minutes, MIN_USDC_NOTIONAL);
    }

    function testPrice() public {
        Order[] memory orders = new Order[](2);
        orders[0] = baseOrder;
        orders[1] = subOrder;
        declareOrder(orders);
        assertEq(polymarketPriceOracle.getPendingPriceData().length, orders.length);
        feedPrice(baseOrder);
        assertEq(polymarketPriceOracle.getPendingPriceData().length, 0);
        checkPrice(baseOrder);
        checkPrice(subOrder);

    }

    function testOrderNotDeclared() public {
        uint256 prev = polymarketPriceOracle.getPendingPriceData().length;
        feedPrice(baseOrder);
        assertEq(polymarketPriceOracle.getPendingPriceData().length, prev);
    }

    function testOrderNotFilled() public {
        handleOrderStatus(baseOrder, false);
        polymarketPriceOracle.proposePrice(baseOrder);      
        feedPrice(baseOrder);
        assertEq(polymarketPriceOracle.getPendingPriceData().length, 1);
    }

    function testOrderExpired() public {
        Order[] memory orders = new Order[](1);
        orders[0] = baseOrder;
        declareOrder(orders);
        uint256 len = polymarketPriceOracle.getPendingPriceData().length;
        vm.warp(block.timestamp + polymarketPriceOracle.getTTL() + 2 minutes);
        feedPrice(baseOrder);
        assertEq(polymarketPriceOracle.getPendingPriceData().length, len-1);
    }

    function declareOrder(Order[] memory orders) internal {
        for(uint i = 0; i < orders.length; i++) {
            handleOrderStatus(orders[i], false);
            polymarketPriceOracle.proposePrice(orders[i]);
            handleOrderStatus(orders[i], true);
        }
    }


    function handleOrderStatus(Order memory order, bool isFilled) internal {
        OrderStatus memory orderStatus;
        orderStatus.isFilledOrCancelled = isFilled;
        orderStatus.remaining =0;
        polymarket._setOrderStatus(order, orderStatus);
    }

    function feedPrice(Order memory) internal {
        polymarketPriceOracle.verifyProposedPrice(0);
    }

    function checkPrice(Order memory order) internal view {
        uint256 expectedPrice = _calcPrice(order);
        uint256 comp = polymarketReal.getComplement(order.tokenId);
        PolymarketPriceOracle.PriceData memory price = polymarketPriceOracle.getPrice(order.tokenId);
        PolymarketPriceOracle.PriceData memory compPrice = polymarketPriceOracle.getPrice(comp);
        assertEq(price.price, expectedPrice);
        assertEq(compPrice.price, ONE - price.price);
        console.logUint(price.price);
        console.logUint(compPrice.price);
        uint256 usdc = (order.side == Side.BUY) ? order.makerAmount : order.takerAmount;
        require(usdc >= MIN_USDC_NOTIONAL, "Order makerAmount is too low");
    }

    function _calcPrice(Order memory order) public view returns(uint256) {
        uint256 collateralAmount = (order.side == Side.BUY) ? order.makerAmount : order.takerAmount;
        uint256 ctfTokenAmount = (order.side == Side.BUY) ? order.takerAmount : order.makerAmount;
        uint256 price = (collateralAmount * ONE) / ctfTokenAmount;
        return price;
    }
}
