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

## Upgrades

Upgrades are currently only via pre-distributed binaries.

There is an `upgrades/` folder on which you can store the binaries. The folder is mounted on the Docker container when running `docker compose run --rm cosmovisor`.

You can then add the upgrades to cosmovisor:

```
docker compose run --rm cosmovisor cosmovisor add-upgrade vx.x.x /upgrades/ledgerd-vx.x.x-linux-amd64 --upgrade-height 123456
```

Latest Cosmovisor (v1.7.1) does not work for the upgrades, `add-upgrade` and `add-batch-upgrade` will successfully create the necessary folders and upgrade-info.json files, and move the binaries. However, it will not apply the upgrades at the expected upgrade height.

For that reason, we're sticking with Cosmovisor v1.6.0, which does not have the `add-batch-upgrade` command, but upgrades via `add-upgrade` will work.

## Version

Lombard Docker uses a semver scheme.

This is lombard-docker v1.0.0
