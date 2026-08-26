# Pocket Pets

Phoenix LiveView Tamagotchi-style virtual pet for the Dispersed hackathon.

## Local

```sh
mix setup
mix phx.server
```

Visit `http://localhost:4000` if that port is free.

## Secrets

Secrets are managed with SOPS and age:

```sh
sops secrets/dispersed.yaml
```

The Dispersed API key is a key pair:

- `dispersed.public_key` maps to `DISPERSED_PUBLIC_KEY` and starts with `pk_`
- `dispersed.secret_key` maps to `DISPERSED_SECRET_KEY` and starts with `sk_`

The local SOPS recipient is configured in `.sops.yaml`.
