#!/bin/bash

source "$(dirname "$0")/lib/ui.sh"
source "$(dirname "$0")/lib/config.sh"

REVIEW_ID=$1

if [[ -z "$REVIEW_ID" ]]; then
    # Fetch all reviews
    curl -s "${API_URL}/reviews" | jq '.'
else
    # Fetch a single review by ID
    curl -s "${API_URL}/reviews" | jq --arg id "$REVIEW_ID" '.[] | select(.id.S == $id)'
fi 