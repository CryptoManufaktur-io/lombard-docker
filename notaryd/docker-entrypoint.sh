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

dasel put -f /cosmos/config/app.toml -v $BLACKLIST_RPC_URL blacklist.rpc_url
dasel put -f /cosmos/config/app.toml -v $BLACKLIST_CONTRACT blacklist.contract

dasel put -f /cosmos/config/app.toml -v $BITCOIN_RPC_HOST bitcoin.host
dasel put -f /cosmos/config/app.toml -v $BITCOIN_DISABLE_TLS bitcoin.disable_tls
dasel put -f /cosmos/config/app.toml -v 1 bitcoin.user
dasel put -f /cosmos/config/app.toml -v 1 bitcoin.pass
dasel put -f /cosmos/config/app.toml -v mainnet bitcoin.params
dasel put -f /cosmos/config/app.toml -v 6 bitcoin.required_confirmations

if [ "${NETWORK}" = "ledger-mainnet-1" ]; then
  # Mainnet config.
  dasel put -f /cosmos/config/app.toml -v $ETH_RPC_URL evm.mainnet.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0x01" evm.mainnet.chain_id
  dasel put -f /cosmos/config/app.toml -v 65 evm.mainnet.required_confirmations
  dasel put -f /cosmos/config/app.toml -v true evm.mainnet.enabled
  
  dasel put -f /cosmos/config/app.toml -v $BSC_RPC_URL evm.bsc.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0x38" evm.bsc.chain_id
  dasel put -f /cosmos/config/app.toml -v 15 evm.bsc.required_confirmations
  dasel put -f /cosmos/config/app.toml -v true evm.bsc.enabled
  
  dasel put -f /cosmos/config/app.toml -v $BASE_RPC_URL evm.base.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0x2105" evm.base.chain_id
  dasel put -f /cosmos/config/app.toml -v 72 evm.base.required_confirmations
  dasel put -f /cosmos/config/app.toml -v true evm.base.enabled
else
  # Testnet config.
  dasel put -f /cosmos/config/app.toml -v $ETH_RPC_URL evm.holesky.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0x4268" evm.holesky.chain_id
  dasel put -f /cosmos/config/app.toml -v 65 evm.holesky.required_confirmations
  dasel put -f /cosmos/config/app.toml -v true evm.holesky.enabled
  
  dasel put -f /cosmos/config/app.toml -v $BSC_RPC_URL evm.bsc_testnet.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0x61" evm.bsc_testnet.chain_id
  dasel put -f /cosmos/config/app.toml -v 15 evm.bsc_testnet.required_confirmations
  dasel put -f /cosmos/config/app.toml -v true evm.bsc_testnet.enabled
  
  dasel put -f /cosmos/config/app.toml -v $BASE_RPC_URL evm.base_sepolia.rpc_url
  dasel put -f /cosmos/config/app.toml -v "0x014a34" evm.base_sepolia.chain_id
  dasel put -f /cosmos/config/app.toml -v 72 evm.base_sepolia.required_confirmations
  dasel put -f /cosmos/config/app.toml -v true evm.base_sepolia.enabled
fi

# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
exec "$@"
