DOTPATH    := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
CANDIDATES := $(wildcard .??*)
EXCLUSIONS := .git .gitmodules
DOTFILES   := $(filter-out $(EXCLUSIONS), $(CANDIDATES))

.DEFAULT_GOAL := help

.PHONY: list
list: ## Show dot files in this repo
	@$(foreach val, $(DOTFILES), ls -dF $(val);)

.PHONY: deploy
deploy: ## Create symlink to home directory
	@echo "Start to deploy dotfiles to home directory."
	@echo ""
	@$(foreach dotfile, $(DOTFILES), ln -sfnv $(abspath $(DOTPATH)/$(dotfile) $(HOME)/$(dotfile));)

.PHONY: run
run: ## Run dotfiles and init scripts
	@echo "Start to run dotfiles in docker container."
	@echo ""
	@docker run -it -v $(DOTPATH):/home/dotfiles-sandbox/dotfiles valbeat/dotfiles-sandbox:latest /bin/zsh

.PHONY: install
install: clean deploy ## Run make deploy

.PHONY: clean
clean: ## Copy target dotfiles to repository
	@echo "Start to clean dotfiles."
	@echo ""
	-@$(foreach dotfile, $(DOTFILES), mv $(abspath $(HOME)/$(dotfile) /tmp/$(dotfile));)

.PHONY: help
help: ## Self-documented Makefile
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

