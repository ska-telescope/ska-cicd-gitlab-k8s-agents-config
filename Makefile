AGENT_KAS_ADDRESS ?= wss://kas.gitlab.com
AGENT_NAME ?=## Agent name associated with the cluster
AGENT_VERSION ?= v15.1.0## Get latest version from: https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/container_registry/1706492?orderBy=NAME&sort=desc&search[]=
AGENT_TOKEN ?=
KUBE_NAMESPACE ?= gitlab
MINIO_USERNAME ?=
MINIO_PASSWORD ?=
RUNNER_REGISTRATION_TOKEN ?=

.DEFAULT_GOAL := help

# define overides for above variables in here
-include PrivateRules.mak

-include .make/base.mk
-include .make/helm.mk
-include .make/k8s.mk

vars:  ## Prints all the defined variables and their values.
	@echo "Current variable settings:"
	@echo "AGENT_NAME=$(AGENT_NAME)"
	@echo "AGENT_TOKEN=$(AGENT_TOKEN)"
	@echo "AGENT_KAS_ADDRESS=$(AGENT_KAS_ADDRESS)"
	@echo "AGENT_VERSION=$(AGENT_VERSION)"
	@echo "KUBE_NAMESPACE=$(KUBE_NAMESPACE)"
	@echo "MINIO_USERNAME=$(MINIO_USERNAME)"
	@echo "MINIO_PASSWORD=$(MINIO_PASSWORD)"
	@echo "RUNNER_REGISTRATION_TOKEN=$(RUNNER_REGISTRATION_TOKEN)"

# Set Chart Values
HELM_RELEASE=$(AGENT_NAME)
K8S_CHART_PARAMS=  \
	--namespace=$(KUBE_NAMESPACE) \
	--create-namespace \
	--set gitlab-agent.image.tag=$(AGENT_VERSION) \
	--set gitlab-agent.config.token=$(AGENT_TOKEN) \
	--set gitlab-agent.config.kasAddress=$(AGENT_KAS_ADDRESS)

HELM_CHARTS_TO_PUBLISH=## Empty: do not publish any chart

agent-runner-secrets:  ## Deploys a secret object needed by Gitlab Runner instances not integrated with Vault.
	kubectl create secret generic gitlab-runner-gitlab-runner \
		--from-literal=gitlab-s3-access-key=$(MINIO_USERNAME) \
		--from-literal=gitlab-s3-secret-key=$(MINIO_PASSWORD) \
		--from-literal=runner-registration-token=$(RUNNER_REGISTRATION_TOKEN) \
		--from-literal=runner-token= \
		--namespace $(KUBE_NAMESPACE) \
		--dry-run=client -o=yaml | kubectl apply -f -

help:  ## Show this help.
	@echo "make targets:"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ": .*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ""; echo "make vars (+defaults):"
	@grep -E '^[0-9a-zA-Z_-]+ \?=.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = " \\?= "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'