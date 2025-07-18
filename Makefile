# Caesari Food Reviews Makefile

.PHONY: run edit help add mkcli-reg

mkcli-reg:
	@source lib/check-mkcli.sh && check-mkcli
	@mkcli a food .
	
# Default target
help:
	@echo " "
	@echo "  view   - Open the food reviews site in your default browser"
	@echo "  add    - Add a new food review interactively"
	@echo " "
	@echo "  ---"
	@echo "  mkcli-reg  - Register the project with mkcli"

# Add new review interactively
add:
	@git pull
	@chmod +x lib/add_review.sh
	@./lib/add_review.sh
	@git add reviews.js
	@git commit -m "Add new review"
	@git push

# Run the static HTML site
view:
	@echo "Opening food reviews site..."
	@open index.html

straight-to-prod:
	@git pull
	@vercel --prod 

edit:
	@echo "Opening project in VS Code..."
	@code .

# Alternative run command for different systems
view-linux:
	@echo "Opening food reviews site (Linux)..."
	@xdg-open index.html

view-windows:
	@echo "Opening food reviews site (Windows)..."
	@start index.html

