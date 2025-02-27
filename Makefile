# 記事作成
create_article:
	@echo "Enter article prefix:"; \
	read prefix; \
	date=$$(date +"%Y%m%d"); \
	npx zenn new:article --slug "$$prefix-$$date"

# 記事をプレビュー
preview:
	npx zenn preview
