#! /bin/bash
# 
# script initializies the serverless backend with the initial reviews (initial-reviews.js)
# - by sending POST request to add review for each of the objects in the initial-reviews.js file

source "$(dirname "$0")/lib/config.sh"
source "$(dirname "$0")/lib/ui.sh"

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    print_colored $RED "jq could not be found. Please install jq to run this script."
    exit 1
fi

# get the initial reviews and clean the file to get a valid JSON
# This removes "window.REVIEWS = " from the beginning and the trailing ";"
initial_reviews_json=$(sed '1s/^window.REVIEWS = //; $s/;$//' ../initial-reviews.js)

if [ -z "$initial_reviews_json" ]; then
    print_colored $RED "Could not read initial reviews from ../initial-reviews.js"
    exit 1
fi

print_colored $BLUE "Initializing reviews..."

# send POST request to add review for each of the objects in the initial-reviews.js file
echo "$initial_reviews_json" | jq -c '.[]' | while read -r review_json; do
    # Using jq to create the JSON payload.
    # It selects only the fields relevant for a new review, and removes any that are null.
    # It also removes any 'id' field from the source, as the backend will generate it.
    json_payload=$(echo "$review_json" | jq 'del(.id) | {place, dish, rating, reviewer, comment, date, category} | del(..|select(.==null))')

    response=$(curl -s -X POST -H "Content-Type: application/json" -d "$json_payload" "${API_URL}/reviews")
    
    # A successful response should contain the review with an id.
    # We check for the presence of an 'id' field in the JSON response.
    if echo "$response" | jq -e '.id' >/dev/null 2>&1; then
        place=$(echo "$review_json" | jq -r '.place')
        dish=$(echo "$review_json" | jq -r '.dish')
        print_colored $GREEN "✓ Review for '$dish' at '$place' added successfully!"
    else
        place=$(echo "$review_json" | jq -r '.place')
        dish=$(echo "$review_json" | jq -r '.dish')
        print_colored $RED "Failed to add review for '$dish' at '$place'. Server response:"
        echo "$response"
    fi
done

print_colored $GREEN "Review initialization complete! 🎉"
