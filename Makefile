COMPOSE_USER=$(shell id -u):$(shell id -g)

# Linting
########################################################################

.PHONY: lint
lint: lint-plugin lint-bash lint-docker lint-hcl

.PHONY: lint-plugin
lint-plugin:
	docker-compose run --rm plugin-linter

.PHONY: lint-bash
lint-bash:
	./pants lint ::

.PHONY: lint-docker
lint-docker:
	docker-compose run --rm hadolint

.PHONY: lint-hcl
lint-hcl:
	docker-compose run --rm hcl-linter

# Formatting
########################################################################

.PHONY: format
format: format-hcl format-bash

.PHONY: format-hcl
format-hcl:
	docker-compose run --rm --user=${COMPOSE_USER} hcl-formatter

.PHONY: format-bash
format-bash:
	./pants fmt ::

# Testing
########################################################################

.PHONY: test
test: test-plugin

.PHONY: test-plugin
test-plugin:
	docker-compose run --rm plugin-tester

# Containers
########################################################################

.PHONY: image
image:
	docker buildx bake

.PHONY: image-push
image-push:
	docker buildx bake --push

########################################################################

.PHONY: all
all: format lint test image

########################################################################

.PHONY: update-buildkite-shared
update-buildkite-shared: ## Pull in changes from grapl-security/buildkite-common
	git subtree pull --prefix .buildkite/shared git@github.com:grapl-security/buildkite-common.git main --squash
