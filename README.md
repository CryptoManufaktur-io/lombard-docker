# lombard-docker

Docker compose for Lombard.

Meant to be used with [central-proxy-docker](https://github.com/CryptoManufaktur-io/central-proxy-docker) for traefik
and Prometheus remote write; use `:ext-network.yml` in `COMPOSE_FILE` inside `.env` in that case.

## Quick setup

Run `cp default.env .env`, then `nano .env`, and update values like MONIKER, NETWORK, and SNAPSHOT.

If you want the consensus node RPC ports exposed locally, use `rpc-shared.yml` in `COMPOSE_FILE` inside `.env`.

- `./lombardd install` brings in docker-ce, if you don't have Docker installed already.
- `./lombardd up`

To update the software, run `./lombardd update` and then `./lombardd up`

### CLI

The Cosmovisor bin can be executed:

- `docker compose run --rm cosmovisor cosmovisor add-upgrade ...`

An image with the `lombardd` binary is also avilable, e.g:

- `docker compose run --rm cli version`

## Version

Lombard Docker uses a semver scheme.

This is lombard-docker v1.0.0
