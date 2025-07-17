# Caesari Food Reviews Makefile

.PHONY: run edit help add

# Default target
help:
	@echo "Available commands:"
	@echo "  make view   - Open the food reviews site in your default browser"
	@echo "  make add   - Add a new food review interactively"
	@echo "  make edit  - Open the project with `code`"
	@echo "  make help  - Show this help message"

# Add new review interactively
add:
	@chmod +x add_review.sh
	@./add_review.sh

# Run the static HTML site
view:
	@node build_reviews.js
	@echo "Opening food reviews site..."
	@open index.html

# Open project in VS Code
edit:
	@echo "Opening project in VS Code..."
	@code .

# Alternative run command for different systems
run-linux:
	@echo "Opening food reviews site (Linux)..."
	@xdg-open index.html

run-windows:
	@echo "Opening food reviews site (Windows)..."
	@start index.html

