#!/bin/bash
# Script untuk run Flutter dengan config yang benar.
BACKEND_URL="https://menantuidaman-stellarapachackathon-production.up.railway.app"
RP_ID="menantuidaman-stellarapachackathon-production.up.railway.app"

flutter run \
  --dart-define=BACKEND_URL=$BACKEND_URL \
  --dart-define=RP_ID=$RP_ID \
  "$@"
