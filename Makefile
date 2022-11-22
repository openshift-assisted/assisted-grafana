BUILD_IMAGE ?= assisted-grafana:latest

.PHONY: all
all: validate

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: image-build
image-build: ## Build docker image to run Makefile targets
	podman build -t $(BUILD_IMAGE) -f Dockerfile.build .

.PHONY: dev-validate
dev-validate: image-build ## Run `validate` target running through a container
	podman run -v $(shell pwd):/app:z -w /app --entrypoint=make $(BUILD_IMAGE) validate

.PHONY: validate
validate: ## Validate dashboards manifests
	kubeconform -strict -verbose dashboards/
