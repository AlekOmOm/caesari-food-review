#!/bin/bash

source "$(dirname "$0")/lib/ui.sh"
source "$(dirname "$0")/lib/config.sh"

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    print_colored $RED "jq could not be found. Please install jq to run this script."
    exit 1
fi

print_colored $BLUE "=== Food Review Entry ==="
echo

while true; do
    read -p "$(print_colored $YELLOW "Place name: ")" place
    if [[ -n "$place" ]]; then break; fi
    print_colored $RED "Place name cannot be empty!"
done

while true; do
    read -p "$(print_colored $YELLOW "Dish name: ")" dish
    if [[ -n "$dish" ]]; then break; fi
    print_colored $RED "Dish name cannot be empty!"
done

while true; do
    read -p "$(print_colored $YELLOW "Rating (1-10): ")" rating
    if validate_rating "$rating"; then break; fi
    print_colored $RED "Rating must be a number between 1 and 10!"
done

while true; do
    read -p "$(print_colored $YELLOW "Reviewer name: ")" reviewer
    if [[ -n "$reviewer" ]]; then break; fi
    print_colored $RED "Reviewer name cannot be empty!"
done

read -p "$(print_colored $YELLOW "Comment (optional): ")" comment

# The backend now handles date and category, so we can remove that logic here.

json_payload=$(cat <<EOF
{
  "place": "$place",
  "dish": "$dish",
  "rating": $rating,
  "reviewer": "$reviewer",
  "comment": "$comment"
}
EOF
)

response=$(curl -s -X POST -H "Content-Type: application/json" -d "$json_payload" "${API_URL}/reviews")

if echo "$response" | jq -e '.id' >/dev/null 2>&1; then
    print_colored $GREEN "✓ Review added successfully!"
    print_colored $GREEN "Review entry complete! 🎉"
else
    print_colored $RED "Failed to add review. Server response:"
    echo "$response"
fi