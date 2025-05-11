# Polymarket Price Oracle Keeper Node

A TypeScript-based keeper node for the Polymarket Price Oracle. This service monitors WebSocket endpoints for relevant transactions, filters them, and broadcasts price updates to the blockchain.

## Directory Structure

```
./
│
├── package.json         # Project dependencies and scripts
├── tsconfig.json        # TypeScript configuration
├── .env.example         # Example environment variables
├── README.md            # This file
│
└── src/
    ├── index.ts         # Main entry point that bootstraps the feed → tx path
    │
    ├── config/          # Environment variables, constants, ABI, addresses
    │   └── index.ts
    │
    ├── feeds/           # Input layer
    │   ├── wsPool.ts    # Opens/monitors multiple WS endpoints
    │   └── mempoolFilter.ts # Dedupe + basic "isTarget" filter
    │
    ├── tx/              # Output layer
    │   ├── template.ts  # Pre-signed raw RLP tx blob
    │   ├── signer.ts    # Patches calldata & gas (no logic)
    │   └── broadcaster.ts # Sends to many RPCs + Protect
    │
    ├── utils/
    │   └── lruCache.ts  # LRU cache implementation
    │
    └── types.ts         # TypeScript type definitions
```

## Setup

1. Install dependencies:
   ```
   npm install
   ```

2. Copy the example environment file and update with your values:
   ```
   cp .env.example .env
   ```

3. Build the project:
   ```
   npm run build
   ```

4. Start the keeper node:
   ```
   npm start
   ```

## Development

For local development with hot reloading:
```
npm run dev
```

## Environment Variables

See `.env.example` for all required environment variables.
