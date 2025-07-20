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
