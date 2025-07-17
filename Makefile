# Caesari Food Reviews Makefile

.PHONY: run edit help

# Default target
help:
	@echo "Available commands:"
	@echo "  make run   - Open the food reviews site in your default browser"
	@echo "  make edit  - Open the project in VS Code"
	@echo "  make help  - Show this help message"

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
