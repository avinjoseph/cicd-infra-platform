#!/usr/bin/env bash
# Polls the deployed service's /health endpoint after a release and fails
# (non-zero exit) if it doesn't become healthy within the timeout.
#
# Usage: ./validate_deployment.sh <base_url> [max_attempts] [sleep_seconds]

set -euo pipefail

BASE_URL="${1:?Usage: validate_deployment.sh <base_url> [max_attempts] [sleep_seconds]}"
MAX_ATTEMPTS="${2:-10}"
SLEEP_SECONDS="${3:-5}"

echo "Validating deployment at ${BASE_URL}/health"

attempt=1
while (( attempt <= MAX_ATTEMPTS )); do
  http_code=$(curl -s -o /tmp/health_response.json -w "%{http_code}" "${BASE_URL}/health" || echo "000")

  if [[ "$http_code" == "200" ]]; then
    status=$(python3 -c "import json;print(json.load(open('/tmp/health_response.json')).get('status',''))" 2>/dev/null || echo "")
    if [[ "$status" == "ok" ]]; then
      echo "Attempt ${attempt}/${MAX_ATTEMPTS}: healthy (HTTP 200, status=ok)"
      exit 0
    fi
  fi

  echo "Attempt ${attempt}/${MAX_ATTEMPTS}: not healthy yet (HTTP ${http_code}), retrying in ${SLEEP_SECONDS}s..."
  sleep "$SLEEP_SECONDS"
  ((attempt++))
done

echo "Deployment did not become healthy after ${MAX_ATTEMPTS} attempts." >&2
exit 1
