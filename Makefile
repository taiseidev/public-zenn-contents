create_article:
	@echo "Enter article prefix:"; \
	read prefix; \
	date=$$(date +"%Y%m%d"); \
	npx zenn new:article --slug "$$prefix-$$date"

preview:
	npx zenn preview
