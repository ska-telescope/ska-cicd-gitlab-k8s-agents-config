AGENT_KAS_ADDRESS ?= wss://kas.gitlab.com
AGENT_VERSION ?= v14.8.1## Get latest version from: https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/container_registry/1706492?orderBy=NAME&sort=desc&search[]=
AGENT_TOKEN ?=
NAMESPACE ?= gitlab
MINIO_USERNAME ?=
MINIO_PASSWORD ?=
RUNNER_REGISTRATION_TOKEN ?=

.DEFAULT_GOAL := help

# define overides for above variables in here
-include PrivateRules.mak

vars:  ## Variables
	@echo "Current variable settings:"
	@echo "AGENT_TOKEN=$(AGENT_TOKEN)"
	@echo "AGENT_KAS_ADDRESS=$(AGENT_KAS_ADDRESS)"
	@echo "AGENT_VERSION=$(AGENT_VERSION)"
	@echo "NAMESPACE=$(NAMESPACE)"
	@echo "MINIO_USERNAME=$(MINIO_USERNAME)"
	@echo "MINIO_PASSWORD=$(MINIO_PASSWORD)"
	@echo "RUNNER_REGISTRATION_TOKEN=$(RUNNER_REGISTRATION_TOKEN)"

generate-agent-manifest:
	docker run --pull=always --rm registry.gitlab.com/gitlab-org/cluster-integration/gitlab-agent/cli:stable generate \
		--agent-token=$(AGENT_TOKEN) \
		--kas-address=$(AGENT_KAS_ADDRESS) \
		--agent-version $(AGENT_VERSION) \
		--namespace $(NAMESPACE) > deploy-agent-manifest.yaml

agent:
	kubectl apply -f deploy-agent-manifest.yaml

agent-runner-secrets:
	kubectl create secret generic gitlab-runner-gitlab-runner \
		--from-literal=gitlab-s3-access-key=$(MINIO_USERNAME) \
		--from-literal=gitlab-s3-secret-key=$(MINIO_PASSWORD) \
		--from-literal=runner-registration-token=$(RUNNER_REGISTRATION_TOKEN) \
		--from-literal=runner-token= \
		--namespace $(NAMESPACE) \
		--dry-run=client -o=yaml | kubectl apply -f -

help:  ## Show this help.
	@echo "make targets:"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ": .*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ""; echo "make vars (+defaults):"
	@grep -E '^[0-9a-zA-Z_-]+ \?=.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = " \\?= "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'