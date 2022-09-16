DOCKER_COMPOSE_CHECK := docker compose run --rm
NONROOT_DOCKER_COMPOSE_CHECK := $(DOCKER_COMPOSE_CHECK) --user=$(shell id --user):$(shell id --group)
PANTS_SHELL_FILTER := ./pants --filter-target-type=shell_source,shunit2_test

.PHONY: all
all: format
all: lint
all: test
all: image
all: ## Run all operations

.PHONY: help
help: ## Print this help
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make <target>\n"} \
		 /^[a-zA-Z0-9_-]+:.*?##/ { printf "  %-46s %s\n", $$1, $$2 } \
		 /^##@/ { printf "\n%s\n", substr($$0, 5) } ' \
		 $(MAKEFILE_LIST)
	@printf '\n'

##@ Linting
########################################################################

.PHONY: lint
lint: lint-docker
lint: lint-hcl
lint: lint-plugin
lint: lint-shell
lint: ## Perform lint checks on all files

.PHONY: lint-docker
lint-docker:  ## Lint Dockerfiles
	./pants --filter-target-type=docker_image lint ::

.PHONY: lint-hcl
lint-hcl: ## Lint HCL files
	$(DOCKER_COMPOSE_CHECK) hcl-linter

.PHONY: lint-plugin
lint-plugin: ## Lint the Buildkite plugin metadata
	$(DOCKER_COMPOSE_CHECK) plugin-linter

.PHONY: lint-shell
lint-shell: ## Lint the shell scripts
	$(PANTS_SHELL_FILTER) lint ::

##@ Formatting
########################################################################

.PHONY: format
format: format-hcl
format: format-shell
format: ## Automatically format all code

.PHONY: format-hcl
format-hcl: ## Format HCL files
	$(NONROOT_DOCKER_COMPOSE_CHECK) hcl-formatter

.PHONY: format-shell
format-shell: ## Format shell scripts
	$(PANTS_SHELL_FILTER) fmt ::

##@ Testing
########################################################################

.PHONY: test
test: test-plugin
test: ## Run all tests

.PHONY: test-plugin
test-plugin: ## Test the Buildkite plugin locally (does *not* run a Buildkite pipeline)
	$(DOCKER_COMPOSE_CHECK) plugin-tester

##@ Containers
########################################################################

.PHONY: image
image: ## Build the Codecov container image
	docker buildx bake

.PHONY: image-push
image-push: ## Build *and* push the Codecov container image to a repository
	docker buildx bake --push
