COMPOSE_USER=$(shell id -u):$(shell id -g)

# Linting
########################################################################

.PHONY: lint
lint: lint-plugin lint-shell lint-docker lint-hcl

.PHONY: lint-plugin
lint-plugin:
	docker-compose run --rm plugin-linter

.PHONY: lint-shell
lint-shell:
	./pants lint ::

.PHONY: lint-docker
lint-docker:
	./pants filter --target-type=docker_image :: | xargs ./pants lint

.PHONY: lint-hcl
lint-hcl:
	docker-compose run --rm hcl-linter

# Formatting
########################################################################

.PHONY: format
format: format-hcl format-shell

.PHONY: format-hcl
format-hcl:
	docker-compose run --rm --user=${COMPOSE_USER} hcl-formatter

.PHONY: format-shell
format-shell:
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
