#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f /cosmos/.initialized ]]; then
  echo "Initializing!"

  echo "Running init..."
  ledgerd init notaryd --chain-id $NETWORK --home /cosmos --overwrite

  touch /cosmos/.initialized
else
  echo "Already initialized!"
fi

echo "Updating config..."

dasel put -f /cosmos/config/config.toml -t bool -v true instrumentation.prometheus

dasel put -f /cosmos/config/app.toml -v $SANCTIONS_URL sanctions.url
dasel put -f /cosmos/config/app.toml -v $BLACKLIST_RPC_URL blacklist.rpc_url
dasel put -f /cosmos/config/app.toml -v $BLACKLIST_CONTRACT blacklist.contract

dasel put -f /cosmos/config/app.toml -v $BITCOIN_RPC_HOST bitcoin.host
dasel put -f /cosmos/config/app.toml -v $BITCOIN_DISABLE_TLS bitcoin.disable_tls
dasel put -f /cosmos/config/app.toml -v "$BITCOIN_USER" bitcoin.user
dasel put -f /cosmos/config/app.toml -v "$BITCOIN_PASS" bitcoin.pass
dasel put -f /cosmos/config/app.toml -v mainnet bitcoin.params
dasel put -f /cosmos/config/app.toml -v 6 bitcoin.required_confirmations
dasel put -f /cosmos/config/app.toml -v "10s" bitcoin.timeout

dasel put -f /cosmos/config/client.toml -v $NETWORK chain-id

if [ "${NETWORK}" = "ledger-mainnet-1" ]; then
  # Mainnet config.
  dasel put -f /cosmos/config/app.toml -v $ETH_RPC_URL evm.mainnet.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0x01" evm.mainnet.chain_id
  dasel put -f /cosmos/config/app.toml -v 65 evm.mainnet.required_confirmations
  dasel put -f /cosmos/config/app.toml -v true -t bool evm.mainnet.enabled

  dasel put -f /cosmos/config/app.toml -v $BSC_RPC_URL evm.bsc.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0x38" evm.bsc.chain_id
  dasel put -f /cosmos/config/app.toml -v 15 evm.bsc.required_confirmations
  dasel put -f /cosmos/config/app.toml -v true -t bool evm.bsc.enabled

  dasel put -f /cosmos/config/app.toml -v $BASE_RPC_URL evm.base.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0x2105" evm.base.chain_id
  dasel put -f /cosmos/config/app.toml -v 72 evm.base.required_confirmations
  dasel put -f /cosmos/config/app.toml -v true -t bool evm.base.enabled

  dasel put -f /cosmos/config/app.toml -v $SUI_RPC_URL sui.mainnet.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0x35834a8a" sui.mainnet.chain_id
  dasel put -f /cosmos/config/app.toml -v $SUI_PACKAGE_ID sui.mainnet.package_id

  dasel put -f /cosmos/config/app.toml -v $SONIC_RPC_URL evm.sonic.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0x92" evm.sonic.chain_id
  dasel put -f /cosmos/config/app.toml -v 72 evm.sonic.required_confirmations
  dasel put -f /cosmos/config/app.toml -v true -t bool evm.sonic.enabled

  dasel put -f /cosmos/config/app.toml -v $KATANA_RPC_URL evm.katana.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0xb67d2" evm.katana.chain_id
  dasel put -f /cosmos/config/app.toml -v 3600 evm.katana.required_confirmations
  dasel put -f /cosmos/config/app.toml -v true -t bool evm.katana.enabled
  dasel put -f /cosmos/config/app.toml -v "0x00000000000000000000000000000000000000000000000000000000000b67d2" katana.chain_id
  dasel put -f /cosmos/config/app.toml -v "0xB0F70C0bD6FD87dbEb7C10dC692a2a6106817072" katana.native_lbtc_address

  dasel put -f /cosmos/config/app.toml -v http://ledgerd:26657 cosmos.ledger.rpc_url
  dasel put -f /cosmos/config/app.toml -v "ledger-mainnet-1" cosmos.ledger.chain_id
  dasel put -f /cosmos/config/app.toml -v true -t bool cosmos.ledger.enabled

else
  # Testnet config.
  dasel put -f /cosmos/config/app.toml -v $ETH_RPC_URL evm.holesky.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0x4268" evm.holesky.chain_id
  dasel put -f /cosmos/config/app.toml -v 65 evm.holesky.required_confirmations
  dasel put -f /cosmos/config/app.toml -v true -t bool evm.holesky.enabled

  dasel put -f /cosmos/config/app.toml -v $BSC_RPC_URL evm.bsc_testnet.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0x61" evm.bsc_testnet.chain_id
  dasel put -f /cosmos/config/app.toml -v 15 evm.bsc_testnet.required_confirmations
  dasel put -f /cosmos/config/app.toml -v true -t bool evm.bsc_testnet.enabled

  dasel put -f /cosmos/config/app.toml -v $BASE_RPC_URL evm.base_sepolia.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0x014a34" evm.base_sepolia.chain_id
  dasel put -f /cosmos/config/app.toml -v 72 evm.base_sepolia.required_confirmations
  dasel put -f /cosmos/config/app.toml -v true -t bool evm.base_sepolia.enabled

  dasel put -f /cosmos/config/app.toml -v $SUI_RPC_URL sui.testnet.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0x4c78adac" sui.testnet.chain_id
  dasel put -f /cosmos/config/app.toml -v $SUI_PACKAGE_ID sui.testnet.package_id

  dasel put -f /cosmos/config/app.toml -v $SONIC_RPC_URL evm.sonic_testnet.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0xdede" evm.sonic_testnet.chain_id
  dasel put -f /cosmos/config/app.toml -v 72 evm.sonic_testnet.required_confirmations
  dasel put -f /cosmos/config/app.toml -v true -t bool evm.sonic_testnet.enabled

  dasel put -f /cosmos/config/app.toml -v $INK_RPC_URL evm.ink_sepolia.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0xba5ed" evm.ink_sepolia.chain_id
  dasel put -f /cosmos/config/app.toml -v 1800 evm.ink_sepolia.required_confirmations
  dasel put -f /cosmos/config/app.toml -v true -t bool evm.ink_sepolia.enabled

  dasel put -f /cosmos/config/app.toml -v $KATANA_RPC_URL evm.katana_testnet.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0x1F977" evm.katana_testnet.chain_id
  dasel put -f /cosmos/config/app.toml -v 3600 evm.katana_testnet.required_confirmations
  dasel put -f /cosmos/config/app.toml -v true -t bool evm.katana_testnet.enabled
  dasel put -f /cosmos/config/app.toml -v "0x000000000000000000000000000000000000000000000000000000000001F977" katana.chain_id
  dasel put -f /cosmos/config/app.toml -v "0x20eA7b8ABb4B583788F1DFC738C709a2d9675681" katana.native_lbtc_address

  dasel put -f /cosmos/config/app.toml -v $SOLANA_RPC_URL solana.devnet.rpc_url
  dasel put -f /cosmos/config/app.toml -v "EtWTRABZaYq6iMfeYKouRu166VU2xqa1wcaWoxPkrZBG" solana.devnet.genesis_hash

  dasel put -f /cosmos/config/app.toml -v http://ledgerd:26657 cosmos.ledger_testnet.rpc_url
  dasel put -f /cosmos/config/app.toml -v "ledger-testnet-1" cosmos.ledger_testnet.chain_id
  dasel put -f /cosmos/config/app.toml -v true -t bool cosmos.ledger_testnet.enabled

  dasel put -f /cosmos/config/app.toml -v "https://ethereum-sepolia-rpc.publicnode.com" evm.sepolia.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0xaa36a7" evm.sepolia.chain_id
  dasel put -f /cosmos/config/app.toml -v 64 evm.sepolia.required_confirmations
  dasel put -f /cosmos/config/app.toml -v true -t bool evm.sepolia.enabled

  dasel put -f /cosmos/config/app.toml -v "https://starknet-sepolia.drpc.org" starknet.sepolia.rpc_url
  dasel put -f /cosmos/config/app.toml -v "SN_SEPOLIA" starknet.sepolia.chain_id
  dasel put -f /cosmos/config/app.toml -v "10s" starknet.sepolia.timeout
fi

# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
exec "$@"
