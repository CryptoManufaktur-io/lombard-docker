# lombard-docker

Docker Compose configurations for running Lombard consensus nodes (ledgerd via Cosmovisor) and notary daemons (notaryd) for cross-chain attestation. Maintained by CryptoManufaktur.io.

Meant to be used with [central-proxy-docker](https://github.com/CryptoManufaktur-io/central-proxy-docker) for traefik
and Prometheus remote write; use `:ext-network.yml` in `COMPOSE_FILE` inside `.env` in that case.

## Quick Setup

Run `cp default.env .env`, then `nano .env`, and update values like MONIKER, NETWORK, and SNAPSHOT.

If you want the consensus node RPC ports exposed locally, use `rpc-shared.yml` in `COMPOSE_FILE` inside `.env`.

- `./lombardd install` brings in docker-ce, if you don't have Docker installed already.
- `./lombardd up`

To update the software, run `./lombardd update` and then `./lombardd up`

## Commands

All operations go through the `./ethd` wrapper (also symlinked as `./lombardd`):

```bash
./ethd up              # Start services
./ethd down            # Stop services
./ethd restart         # Restart services
./ethd logs            # View logs (accepts service name filter)
./ethd version         # Show running client versions
./ethd update          # Update client versions and self
./ethd cmd <args>      # Pass-through to docker compose
```

Tool profile commands (key management, upgrades):
```bash
docker compose run --rm cli version
docker compose run --rm create-validator-keys
docker compose run --rm register-validator
docker compose run --rm cosmovisor add-upgrade vx.x.x /upgrades/ledgerd-vx.x.x-linux-amd64 --upgrade-height <height>
```

## Architecture

### Compose File Composition

Services are split across compose files combined via the `COMPOSE_FILE` env var:
- `lombard.yml` — Main consensus node (ledgerd with Cosmovisor)
- `notaryd.yml` — Notary daemon for cross-chain attestation
- `monitoring.yml` — Prometheus metrics via cosmos-validator-watcher
- `rpc-shared.yml` — Expose RPC ports to host
- `ext-network.yml` — Traefik external network integration

All services share a logging config via YAML anchor `x-logging: &logging`.

### Service Profiles

Services tagged with `profiles: ["tools"]` only run on-demand (CLI, key management, cosmovisor upgrades). The main ledgerd service runs by default.

### Container Patterns

- Base image: `debian:bookworm-slim` (alpine for monitoring only)
- Non-root users: ledger (UID 10001), notaryd (UID 10002)
- Data persistence: named volumes mounted at `/cosmos`
- Pull policy: `never` — all images built locally
- Binaries downloaded from `DOWNLOAD_BASE_URL`, never compiled in-container

## Key Conventions

### Configuration Management

TOML config files are manipulated at runtime using `dasel` (copied into every container from `ghcr.io/tomwright/dasel`):
```bash
dasel put -f /cosmos/config/app.toml -v "value" path.to.key
dasel put -f /cosmos/config/app.toml -v true -t bool path.to.bool
```

### Network Branching

Entrypoint scripts branch on the `NETWORK` env var (`ledger-mainnet-1` vs testnet) to apply different chain configurations. Each network has its own set of chain IDs, confirmation counts, and RPC mappings.

### Initialization

First-run initialization is gated by a `/cosmos/.initialized` sentinel file. The entrypoint handles genesis download, snapshot restoration, and state sync configuration before marking initialized.

### Environment Versioning

The `.env` file has an `ENV_VERSION` field. The `ethd` script's `__env_migrate()` function handles schema migrations when new env vars are added. The `__all_vars` array in `ethd` tracks all known variables.

## Upgrades

Upgrades are currently only via pre-distributed binaries.

There is an `upgrades/` folder on which you can store the binaries. The folder is mounted on the Docker container when running `docker compose run --rm cosmovisor`.

You can then add the upgrades to cosmovisor:

```bash
docker compose run --rm cosmovisor add-upgrade vx.x.x /upgrades/ledgerd-vx.x.x-linux-amd64 --upgrade-height 123456
```

Cosmovisor is **pinned to v1.6.0** — v1.7.1+ has a known bug where `add-upgrade` and `add-batch-upgrade` will successfully create the necessary folders and upgrade-info.json files, and move the binaries, but will not apply the upgrades at the expected upgrade height. v1.6.0 does not have the `add-batch-upgrade` command, but upgrades via `add-upgrade` work correctly.

The entrypoint also does automatic version updates: it compares `DAEMON_VERSION` against the running binary and downloads/symlinks the new version if they differ.

Upgrade inspection commands:
```bash
# List staged upgrades
docker compose run --rm --entrypoint ls cosmovisor -la /cosmos/cosmovisor/upgrades/
# Check which version is active (current symlink)
docker compose run --rm --entrypoint ls cosmovisor -la /cosmos/cosmovisor/current
# View upgrade-info for a specific staged upgrade
docker compose run --rm --entrypoint cat cosmovisor /cosmos/cosmovisor/upgrades/<version>/upgrade-info.json
```

## Adding a New Chain RPC

This is the most common change pattern in this repo:

1. **`default.env`** — Add `<CHAIN>_RPC_URL=` variable
2. **`notaryd/docker-entrypoint.sh`** — Add `dasel put` lines in both the mainnet (`ledger-mainnet-1`) and testnet `if/else` blocks:
   ```bash
   dasel put -f /cosmos/config/app.toml -v $<CHAIN>_RPC_URL evm.<chain>.rpc_url
   dasel put -f /cosmos/config/app.toml -v "<hex_chain_id>" evm.<chain>.chain_id
   dasel put -f /cosmos/config/app.toml -v <confirmations> evm.<chain>.required_confirmations
   dasel put -f /cosmos/config/app.toml -v true -t bool evm.<chain>.enabled
   ```
3. **`ethd`** — Add the new variable to the `__all_vars` array in `__env_migrate()` so existing `.env` files get updated

## Version

Lombard Docker uses a semver scheme.

This is lombard-docker v1.0.0
