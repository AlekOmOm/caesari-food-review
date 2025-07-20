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

print_colored $BLUE "Select a review to delete:"
selected_review=$(echo -e "$formatted_reviews" | fzf --height 40% --reverse)

if [[ -z "$selected_review" ]]; then
    echo "No review selected. Aborting."
    exit 0
fi

REVIEW_ID=$(echo "$selected_review" | cut -d'|' -f1 | tr -d ' ')

read -p "Are you sure you want to delete this review? (y/N) " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Deletion cancelled."
    exit 0
fi

response_code=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "${API_URL}/reviews/${REVIEW_ID}")

if [[ "$response_code" -eq 204 ]]; then
    print_colored $GREEN "✓ Review with ID $REVIEW_ID has been deleted."
    print_colored $GREEN "Deletion complete! 🎉"
else
    print_colored $RED "Failed to delete review. Server responded with HTTP status: $response_code"
fi 