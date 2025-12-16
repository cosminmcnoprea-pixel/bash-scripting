#!/usr/bin/env bash
set -e

# get-cloudrun-public-ip.sh
# Small helper script meant to run locally OR in GitHub Actions.
# Prints a "public IP" for a Cloud Run deployment:
# The global Load Balancer IP
# Usage:
#   ./get-cloudrun-public-ip.sh dev
#   ./get-cloudrun-public-ip.sh prod
# Optional env vars:
#   PROJECT_ID, REGION, SERVICE_NAME, LB_IP_NAME

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
mkdir -p "${LOG_DIR}"
LOG_FILE="${LOG_DIR}/get-cloudrun-public-ip.$(date -u +%Y%m%d).log"

log() { printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" | tee -a "${LOG_FILE}" >&2; }
die() { log "ERROR: $*"; exit 1; }

ENVIRONMENT="${1:-}"
if [[ -z "${ENVIRONMENT}" ]]; then
  die "Usage: $0 <dev|prod>"
fi

case "${ENVIRONMENT}" in
  dev)  DEFAULT_PROJECT_ID="global-reach-media-dev" ;;
  prod) DEFAULT_PROJECT_ID="global-reach-media-prod" ;;
  *) die "Unknown environment '${ENVIRONMENT}'. Use dev or prod." ;;
esac

PROJECT_ID="${PROJECT_ID:-${DEFAULT_PROJECT_ID}}"
REGION="${REGION:-europe-west3}"
SERVICE_NAME="${SERVICE_NAME:-php-app}"
LB_IP_NAME="${LB_IP_NAME:-${SERVICE_NAME}-lb-ip}"

command -v gcloud >/dev/null 2>&1 || die "gcloud is missing. On GitHub Actions, run setup-gcloud first."

log "env=${ENVIRONMENT} project=${PROJECT_ID} region=${REGION} service=${SERVICE_NAME}"

LB_IP="$(gcloud compute addresses describe "${LB_IP_NAME}" \
  --global \
  --project "${PROJECT_ID}" \
  --format='value(address)' 2>/dev/null || true)"

if [[ -n "${LB_IP}" ]]; then
  log "LB IP (${LB_IP_NAME}) => ${LB_IP}"
  echo "${LB_IP}"
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    echo "ip=${LB_IP}" >> "${GITHUB_OUTPUT}"
  fi
  exit 0
fi