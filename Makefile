.PHONY: test-plugin
test-plugin:
	docker-compose run --rm tests

.PHONY: lint-plugin
lint-plugin:
	docker-compose run --rm lint

.PHONY: lint-bash
lint-bash:
	./pants lint ::

.PHONY: lint
lint: lint-plugin lint-bash

.PHONY: test
test: test-plugin
