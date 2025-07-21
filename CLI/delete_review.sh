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

echo "$reviews_json"

# We'll create a tab-separated list of reviews for fzf.
# The first column will be the full ID, and the second a shortened ID for display.
# fzf will return the full line, from which we can extract the full ID.
# We also handle null values gracefully by providing "N/A" as a default.
formatted_reviews=$(echo "$reviews_json" | jq -r '
  .[] | 
  [
    .id, 
    (.id[:5]), 
    (.reviewer // "N/A"), 
    ((.rating // "N/A") | tostring), 
    (.dish // "N/A"), 
    (.place // "N/A"), 
    (.category // "N/A"), 
    (.comment // "N/A")
  ] | @tsv
')

# Add a header to the list.
header=$(printf "ID\tShortID\tReviewer\tRating\tDish\tPlace\tCategory\tComment")
formatted_reviews_with_header=$(echo -e "$header\n$formatted_reviews")

print_colored $BLUE "Select a review to delete:"
# We use fzf with options to make it look like a table.
# We skip the first column (full ID) in the fzf view using --with-nth=2..
# The header is also displayed.
selected_review=$(echo -e "$formatted_reviews" | fzf \
  --height 40% \
  --reverse \
  --header="$header" \
  --with-nth=2.. \
  --delimiter='\t' \
  --preview='echo -e {2..} | column -t -s"	"' \
  --preview-window=top:3:wrap)


if [[ -z "$selected_review" ]]; then
    echo "No review selected. Aborting."
    exit 0
fi

# Extract the full ID from the first column of the selected line.
REVIEW_ID=$(echo "$selected_review" | cut -f1)

read -p "Are you sure you want to delete the review with ID '$REVIEW_ID'? (y/N) " confirm
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