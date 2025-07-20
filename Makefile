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
	@echo "  list   - List all food reviews"
	@echo " "
	@echo "  ---"
	@echo "  mkcli-reg  - Register the project with mkcli"

# Run the static HTML site
view:
	@echo "Opening food reviews site..."
	@open https://caesari-food-review.vercel.app

prod:
	@cd frontend && vercel --prod --env PUBLIC_API_URL=https://1u5t1vutr1.execute-api.us-east-1.amazonaws.com


# CLI
.PHONY: add update delete get

ARGS = $(filter-out $@,$(MAKECMDGOALS))

add:
	@cd CLI && ./add_review.sh

update:
	@cd CLI && ./update_review.sh

delete:
	@cd CLI && ./delete_review.sh

get:
	@cd CLI && ./get_review.sh $(ARGS)


# backend
.PHONY: deploy-backend

deploy:
	@if [ ! -d "backend/node_modules" ]; then \
		echo "Node modules not found. Running npm install..."; \
		cd backend && npm install; \
	fi
	@cd backend && ./node_modules/.bin/serverless deploy