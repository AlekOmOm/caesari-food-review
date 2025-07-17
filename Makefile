# Caesari Food Reviews Makefile

.PHONY: run edit help add mkcli-reg

mkcli-reg:
	mkcli a food .

# Default target
help:
	@echo "Available commands:"
	@echo " "
	@echo "  make view   - Open the food reviews site in your default browser"
	@echo "  make add    - Add a new food review interactively"
	@echo " "
	@echo "  ---"
	@echo "  make mkcli-reg  - Register the project with mkcli"

# Add new review interactively
add:
	@chmod +x lib/add_review.sh
	@./lib/add_review.sh
	@git add reviews.js
	@git commit -m "Add new review"
	@git push

# Run the static HTML site
view:
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

