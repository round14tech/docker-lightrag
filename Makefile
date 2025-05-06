# If you update this file, please follow:
# https://www.thapaliya.com/en/writings/well-documented-makefiles/

# Ensure Make is run with bash shell as some syntax below is bash-specific
SHELL := /usr/bin/env bash

ifneq (,$(wildcard ./.env))
		include .env
  	export
endif

cmd-exists-%:
		@hash $(*) > /dev/null 2>&1 || (echo "ERROR: '$(*)' must be installed and available on your PATH."; exit 1)

guard-%:
		@if [ -z '${${*}}' ]; then echo 'ERROR: variable $* not set' && exit 1; fi

.DEFAULT_GOAL := help

help:  ## Display this help
		@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: install
install: ## Install dependencies
		@uv sync --frozen

.PHONY: dev
dev:  ## Run development server
		@uv run lightrag-server
