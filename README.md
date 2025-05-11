# Polymarket Price Oracle

A minimal, battle-tested oracle that **derives price directly from trades that
have *already* cleared on Polymarket’s `CTFExchange`**.  
No off-chain feeds, no committees—just verifiable on-chain data.

---

## ✨ Market-Price Definition

> The *price* of a `tokenId` is the **execution price** of the *most recent* order that  
> 1. is **filled** (fully or partially) on `CTFExchange`;  
> 2. exceeds **`MIN_USDC_NOTIONAL` (= 5 USDC)**;  
> 3. is newer than **`now – TTL` (= 60 seconds)**;  
> 4. is not cancelled.  
>   
> Mathematically:  
> `price = makerAmount / takerAmount * 1e18`  (18-dec fixed-point)

---

## 🔒 Why You Can Trust This Oracle

| Attack Vector                   | Mitigation & Rationale                                                                                         |
|---------------------------------|----------------------------------------------------------------------------------------------------------------|
| **Fake price injection**        | Must reference an on-chain **filled** order (`orderStatus` check).                                             |
| **Wash trading / dust spoof**   | Orders below `MIN_USDC_NOTIONAL` are ignored.                                                                  |
| **Stale data manipulation**     | Hard **`TTL`** forces a fresh price; any honest keeper can overwrite bogus data.                               |
| **Decimal mismatch errors**     | All outputs normalised to **18 dec** regardless of USDC (6 dec) vs CTF (18 dec).                               |
| **Re-org / cancel after fill**  | Price pulled **after** inclusion & cannot be updated if order is later cancelled.                              |
| **Division-by-zero / overflow** | Explicit runtime guards revert invalid states.                                                                 |

---

## 🛡️ Remaining Trust Assumption

The oracle is **permissionless to read** but **liveness-dependent**:  
as long as **≥ 1 honest keeper** calls `declare()` → `commit()` at least once per `TTL`,
the feed stays fresh and manipulation-resistant.

---

## 🚀 Quick Start

```solidity

```
