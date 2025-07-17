#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_colored() {
    echo -e "${1}${2}${NC}"
}

# Function to validate rating (must be between 1-10)
validate_rating() {
    local rating=$1
    if [[ ! $rating =~ ^[0-9]+(\.[0-9]+)?$ ]] || (( $(echo "$rating < 1" | bc -l) )) || (( $(echo "$rating > 10" | bc -l) )); then
        return 1
    fi
    return 0
}

# Function to validate date format (YYYY-MM-DD)
validate_date() {
    local date=$1
    if [[ ! $date =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        return 1
    fi
    return 0
}

print_colored $BLUE "=== Food Review Entry ==="
echo

# Prompt for inputs
while true; do
    read -p "$(print_colored $YELLOW "Place name: ")" place
    if [[ -n "$place" ]]; then
        break
    fi
    print_colored $RED "Place name cannot be empty!"
done

while true; do
    read -p "$(print_colored $YELLOW "Dish name: ")" dish
    if [[ -n "$dish" ]]; then
        break
    fi
    print_colored $RED "Dish name cannot be empty!"
done

while true; do
    read -p "$(print_colored $YELLOW "Rating (1-10): ")" rating
    if validate_rating "$rating"; then
        break
    fi
    print_colored $RED "Rating must be a number between 1 and 10!"
done

while true; do
    read -p "$(print_colored $YELLOW "Reviewer name: ")" reviewer
    if [[ -n "$reviewer" ]]; then
        break
    fi
    print_colored $RED "Reviewer name cannot be empty!"
done

read -p "$(print_colored $YELLOW "Comment (optional): ")" comment

# Default to today's date
default_date=$(date +%Y-%m-%d)
while true; do
    read -p "$(print_colored $YELLOW "Date (YYYY-MM-DD) [default: $default_date]: ")" date
    if [[ -z "$date" ]]; then
        date=$default_date
        break
    elif validate_date "$date"; then
        break
    else
        print_colored $RED "Invalid date format! Use YYYY-MM-DD"
    fi
done

# Category selection
echo
print_colored $BLUE "Select category:"
echo "1) Casual Dining"
echo "2) Fine Dining"
echo "3) Fast Food"
echo "4) Street Food"
echo "5) Coffee/Cafe"
echo "6) Other"

while true; do
    read -p "$(print_colored $YELLOW "Category (1-6): ")" category_choice
    case $category_choice in
        1) category="casual-dining"; break;;
        2) category="fine-dining"; break;;
        3) category="fast-food"; break;;
        4) category="street-food"; break;;
        5) category="coffee-cafe"; break;;
        6) 
            read -p "$(print_colored $YELLOW "Enter custom category: ")" category
            category=$(echo "$category" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
            break;;
        *) print_colored $RED "Invalid choice! Please select 1-6.";;
    esac
done

# Generate filename
filename="${date}_$(echo "$place" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')_$(echo "$dish" | tr '[:upper:]' '[:lower:]' | tr ' ' '_').md"

# Create review content
cat > "$filename" << EOF
place: $place
dish: $dish
rating: $rating
reviewer: $reviewer
comment: $comment
category: $category

---
*Review added on $(date '+%B %d, %Y')*
EOF

print_colored $GREEN "✓ Review saved to: $filename"
echo

# Ask if user wants to add to git
read -p "$(print_colored $YELLOW "Add to git and push to GitHub? (y/n): ")" git_choice
if [[ $git_choice =~ ^[Yy]$ ]]; then
    git add "$filename"
    git commit -m "Add review: $place - $dish ($rating/10)"
    git push
    print_colored $GREEN "✓ Review pushed to GitHub!"
else
    print_colored $YELLOW "Review saved locally. Remember to commit and push manually."
fi

# Update index.html with new review
print_colored $BLUE "Updating index.html with new review..."

# Read current index.html and extract existing reviews
reviews_data=$(cat index.html | grep -A 20 "this.reviews = \[" | grep -E "id:|date:|place:|dish:|rating:|reviewer:|comment:|category:" | head -n -1)

# Generate new review entry
new_review="                    {
                        id: $(date +%s),
                        date: '$date',
                        place: '$place',
                        dish: '$dish',
                        rating: $rating,
                        reviewer: '$reviewer',
                        comment: '$comment',
                        category: '$category'
                    }"

# This is a simplified approach - in production, you'd want a more robust HTML update
print_colored $YELLOW "Note: You'll need to manually update the index.html file with the new review data"
print_colored $YELLOW "Or implement a more sophisticated update mechanism"

echo
print_colored $GREEN "Review entry complete! 🎉"
