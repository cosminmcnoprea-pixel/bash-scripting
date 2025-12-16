## bash-scripting

Small repo with a script + workflow that prints the **Load Balancer public IP**.

### Script
`get-cloudrun-public-ip.sh`:
- takes `dev` or `prod`
- read the global address `${SERVICE_NAME}-lb-ip`

Run locally:

```bash
REGION=europe-west3 SERVICE_NAME=php-app ./get-cloudrun-public-ip.sh dev
```

### GitHub Actions
Workflow: `.github/workflows/get-cloudrun-public-ip.yml`

Secrets needed:
- `WIF_PROVIDER_DEV`, `WIF_SERVICE_ACCOUNT_DEV`
- `WIF_PROVIDER_PROD`, `WIF_SERVICE_ACCOUNT_PROD`

### What this does
`get-cloudrun-public-ip.sh` retrieves the **public IP address** for a Cloud Run deployment.

### What the script prints
- If it finds the LB IP: prints that IP.

### Requirements
- `gcloud` installed and authenticated (WIF isn’t needed locally; standard auth can be used)
- Permission to describe either:
  - the global address (`compute.addresses.get`), or
  - the Cloud Run service (`run.services.get`)

### Usage
From repo root:

```bash
./bash-scripting/get-cloudrun-public-ip.sh dev
./bash-scripting/get-cloudrun-public-ip.sh prod
```
