# Polymarket Price Oracle


> This is a reliable, fully on-chain price oracle for Polymarket's CTFExchange. Here, the price at the time of execution is defined as “price,” and the USD Coin price per 1 CTF token is stored. To ensure that the generated price is reliable, we verify orders that have been executed based on the orderStatus variable of CTFExchange, and then calculate the price using the verified order structure.
Additionally, to ensure that the price is always up-to-date, a two-stage structure of proposal and consensus is implemented. In the proposal stage, orders not yet sent to CTFExchange are stored. After an order is sent to CTFExchange, executing the consensus stage saves the price if it is within the TTL timeframe from the proposal execution. This ensures that the saved price data is always within the TTL timeframe from when it was proposed.

> Invariance conditions:
1. The price that is saved is valid within the TTL from the time it is saved.
2. As long as ctfExchange's orderStatus is functioning normally, only orders that have been matched in the order book will be used for price calculation.

> Mathematically:  
price = (μUSDC / CTF) * 10^(PRICE_DECIMALS)
where μUSDC is the amount of USDC in the order, CTF is the amount of CTF in the order, and PRICE_DECIMALS is the number of decimal places in the price.
