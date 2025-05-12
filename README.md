# Polymarket Price Oracle

```solidity
PolymarketPriceOracle oracle = PolymarketPriceOracle(0x1aA44c933A6718a4BC44064F0067A853c34be9B0);
uint256 price = oracle.getPrice(trumpYesToken.id).price;
bool isLiquidate = trumpYesToken.volume * price <= LT;
```

This contract serves as a secure, trustworthy, and zero-trust price oracle for Polymarket's CTF tokens (such as Yes or No).

A critical issue existed where position tokens from [CTFExchanges](https://github.com/Polymarket/ctf-exchange) like Polymarket, which derive their value from price discovery, could not have their pricing information directly accessed on-chain by smart contracts. This oracle resolves that problem by making prediction market prices reliably available on-chain in a manipulation-resistant form, enabling the use of position tokens within DeFi protocols.

## Invariants

1. **Market Trade Fidelity**: All prices strictly derive from executed trades.
2. **Temporal Integrity**: Price data are valid only within specific time frames; expired information is never accepted.
3. **Price Consistency**: In binary markets, the total price always sums exactly to 1.
4. **Manipulation Resistance**: The two-step validation process (minimum trade size and execution verification) protects against market manipulation.
5. **Permissionlessness**: The entire system requires no privileged operators; participation is open to everyone.

These invariants enable DeFi protocols to safely leverage prediction market data as reliable on-chain information.

## Mechanism
Through a process of order non-fulfillment verification and order fulfillment verification, the oracle ensures both temporal integrity and confirmation of price data.

1. **Non-Fulfillment Verification**:

```solidity
orderStatus.isFilledOrCancelled || orderStatus.remaining > 0 == false
```

2. **Timestamp Recording**:

```solidity
timestamp = block.timestamp
```

3. **Fulfillment Verification**:

```solidity
orderStatus.isFilledOrCancelled && orderStatus.remaining == 0 == true
```

4. **Time Constraint**:

```solidity
block.timestamp - timestamp ≤ TTL
```

Conditions 1 and 3 guarantee the order was executed within the time interval `[timestamp, verification time]`. Condition 4 ensures this interval is no longer than TTL.

∴ Price data is based exclusively on orders executed within TTL from the recorded timestamp.

**Proof of Price Complementarity**
In a binary market, the sum of prices for `token_id` and its complement `complement_id` always equals 1:

```
price + complementPrice == ONE  // where ONE = 10^18
```

# ***build & accelerate infofinance***
Prediction markets compress socially distributed knowledge into scalar values represented as token prices through financial mechanisms, and this price discovery process enables access to collective intelligence. [Infofinance](https://vitalik.eth.limo/general/2024/11/09/infofinance.html) accelerates as position tokens, serving as compressed collective intelligence, gain mass within the expansive DeFi space. This implementation drives that acceleration. build on infofinance

