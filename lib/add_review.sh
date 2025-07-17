#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_colored() {
    echo -e "${1}${2}${NC}"
}

validate_rating() {
    local rating=$1
    if [[ ! $rating =~ ^[0-9]+(\.[0-9]+)?$ ]] || (( $(echo "$rating < 1" | bc -l) )) || (( $(echo "$rating > 10" | bc -l) )); then
        return 1
    fi
    return 0
}

validate_date() {
    local date=$1
    if [[ ! $date =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        return 1
    fi
    return 0
}

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

default_date=$(date +%Y-%m-%d)
while true; do
    read -p "$(print_colored $YELLOW "Date (YYYY-MM-DD) [default: $default_date]: ")" date
    if [[ -z "$date" ]]; then date=$default_date; break; fi
    if validate_date "$date"; then break; fi
    print_colored $RED "Invalid date format! Use YYYY-MM-DD"
done

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

export PLACE="$place"
export DISH="$dish"
export RATING="$rating"
export REVIEWER="$reviewer"
export COMMENT="$comment"
export DATE="$date"
export CATEGORY="$category"

node - <<'NODE'
const fs=require('fs');
const path=require('path');
const file=path.resolve(process.cwd(),'reviews.js');
let reviews=[];
if(fs.existsSync(file)){
  const txt=fs.readFileSync(file,'utf-8').trim();
  const match=txt.match(/\[.*\]/s);
  if(match)reviews=JSON.parse(match[0]);
}
const nextId=reviews.length?Math.max(...reviews.map(r=>r.id||0))+1:1;
reviews.push({
  place:process.env.PLACE,
  dish:process.env.DISH,
  rating:parseFloat(process.env.RATING),
  reviewer:process.env.REVIEWER,
  comment:process.env.COMMENT,
  category:process.env.CATEGORY,
  date:process.env.DATE,
  id:nextId
});
fs.writeFileSync(file,`window.REVIEWS = ${JSON.stringify(reviews,null,2)};`);
NODE

print_colored $GREEN "✓ Review added to reviews.js"
print_colored $YELLOW "view it at: https://caesari-food-review.vercel.app/"
print_colored $GREEN "Review entry complete! 🎉"