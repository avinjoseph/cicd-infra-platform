#!/usr/bin/env bash
# Rolls an ECS service back to its previous stable task definition revision.
# Intended to run when validate_deployment.sh reports a failed release.
#
# Usage: ./rollback.sh <cluster_name> <service_name>

set -euo pipefail

CLUSTER="${1:?Usage: rollback.sh <cluster_name> <service_name>}"
SERVICE="${2:?Usage: rollback.sh <cluster_name> <service_name>}"

echo "Fetching current task definition family for ${SERVICE}..."
CURRENT_TD_ARN=$(aws ecs describe-services \
  --cluster "$CLUSTER" \
  --services "$SERVICE" \
  --query 'services[0].taskDefinition' \
  --output text)

FAMILY=$(echo "$CURRENT_TD_ARN" | sed -E 's#.*/([^:]+):[0-9]+#\1#')
CURRENT_REVISION=$(echo "$CURRENT_TD_ARN" | sed -E 's#.*:([0-9]+)$#\1#')
PREVIOUS_REVISION=$((CURRENT_REVISION - 1))

if (( PREVIOUS_REVISION < 1 )); then
  echo "No previous revision to roll back to (current is revision 1)." >&2
  exit 1
fi

PREVIOUS_TD="${FAMILY}:${PREVIOUS_REVISION}"
echo "Rolling back ${SERVICE} from revision ${CURRENT_REVISION} to ${PREVIOUS_TD}..."

aws ecs update-service \
  --cluster "$CLUSTER" \
  --service "$SERVICE" \
  --task-definition "$PREVIOUS_TD" \
  --force-new-deployment

echo "Waiting for service to stabilize on the previous revision..."
aws ecs wait services-stable --cluster "$CLUSTER" --services "$SERVICE"

echo "Rollback complete. ${SERVICE} is now running ${PREVIOUS_TD}."
