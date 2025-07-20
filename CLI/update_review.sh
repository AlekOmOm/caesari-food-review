#!/bin/bash

source "$(dirname "$0")/lib/ui.sh"
source "$(dirname "$0")/lib/config.sh"

command -v fzf >/dev/null 2>&1 || { print_colored $RED "fzf is required but it's not installed. Please install it (e.g. 'brew install fzf'). Aborting."; exit 1; }
command -v jq >/dev/null 2>&1 || { print_colored $RED "jq is required but it's not installed. Please install it (e.g. 'brew install jq'). Aborting."; exit 1; }

print_colored $BLUE "Fetching reviews..."
reviews_json=$(curl -s "${API_URL}/reviews")

if ! echo "$reviews_json" | jq . > /dev/null 2>&1; then
    print_colored $RED "Failed to fetch or parse reviews. Please check your connection and API_URL."
    exit 1
fi

if [ "$(echo "$reviews_json" | jq 'length')" -eq 0 ]; then
    print_colored $YELLOW "No reviews found."
    exit 0
fi

formatted_reviews=$(echo "$reviews_json" | jq -r '.[] | "\(.id) | \(.review.place) - \(.review.dish) by \(.review.reviewer)"')

print_colored $BLUE "Select a review to update:"
selected_review=$(echo -e "$formatted_reviews" | fzf --height 40% --reverse)

if [[ -z "$selected_review" ]]; then
    echo "No review selected. Aborting."
    exit 0
fi

REVIEW_ID=$(echo "$selected_review" | cut -d'|' -f1 | tr -d ' ')

print_colored $BLUE "=== Updating Review: $selected_review ==="
print_colored $BLUE "Enter new values. Press Enter to skip a field."
echo

read -p "$(print_colored $YELLOW "New place name: ")" place
read -p "$(print_colored $YELLOW "New dish name: ")" dish
read -p "$(print_colored $YELLOW "New rating (1-10): ")" rating
read -p "$(print_colored $YELLOW "New reviewer name: ")" reviewer
read -p "$(print_colored $YELLOW "New comment: ")" comment

json_payload=$(jq -n '{}')
[[ -n "$place" ]] && json_payload=$(echo "$json_payload" | jq --arg p "$place" '. + {place: $p}')
[[ -n "$dish" ]] && json_payload=$(echo "$json_payload" | jq --arg d "$dish" '. + {dish: $d}')
if [[ -n "$rating" ]]; then
  if validate_rating "$rating"; then
    json_payload=$(echo "$json_payload" | jq --argjson r "$rating" '. + {rating: $r}')
  else
    print_colored $RED "Invalid rating. It must be a number between 1 and 10. Aborting."
    exit 1
  fi
fi
[[ -n "$reviewer" ]] && json_payload=$(echo "$json_payload" | jq --arg r "$reviewer" '. + {reviewer: $r}')
[[ -n "$comment" ]] && json_payload=$(echo "$json_payload" | jq --arg c "$comment" '. + {comment: $c}')

if [[ "$json_payload" == "{}" ]]; then
    print_colored $YELLOW "No changes provided. Aborting."
    exit 0
fi

print_colored $BLUE "Sending update for review ID: $REVIEW_ID"

response_body_and_code=$(curl -s -w "\n%{http_code}" -X PUT \
    -H "Content-Type: application/json" \
    -d "$json_payload" \
    "${API_URL}/reviews/${REVIEW_ID}")

http_code=$(echo "$response_body_and_code" | tail -n1)
response_body=$(echo "$response_body_and_code" | sed '$d')

if [[ "$http_code" -eq 200 ]]; then
    print_colored $GREEN "✓ Review ID $REVIEW_ID updated successfully!"
else
    print_colored $RED "Failed to update review. Server responded with HTTP status: $http_code"
    if [[ -n "$response_body" ]]; then
        echo "Response body:"
        echo "$response_body" | jq .
    fi
    exit 1
fi 