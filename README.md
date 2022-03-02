SKA CICD Gitlab K8s Agents Config
=================================

This repository stores the Gitlab K8s Agents configuration files, which connects the Kubernetes clusters infrastructures with Gitlab and allows the respective KUBECONFIG files to be injected into the pipelines.

Adding and configuring new agents
---------------------------------

To add new agents, a configuration file must be created in the following location in this repository: `.gitlab/agents/<agent-name>/config.yaml`. After this file is added, the agent can be registered in the `Kubernetes clusters` page under `Infrastructure` on the side panel of this repository.

After the agent is registered, a token will be displayed with instructions on how to install the agent on the target Kubernetes cluster.

For more information, see the [Gitlab documentation](https://docs.gitlab.com/ee/user/clusters/agent/repository.html#agent-configuration-repository) on how to configure the agent repository.

Agents
------

Run `make generate-agent-manifest` to generate the agent manifest file (requires docker to be installed). This step expects that an agent has been registered in the [`ska-telescope/ska-cicd-gitlab-k8s-agents-config`](https://gitlab.com/ska-telescope/ska-cicd-gitlab-k8s-agents-config) repository and a token as been obtained. Furthermore, the following environment variables are used:

```console
AGENT_TOKEN=... # The agent access token obtained from Gitlab upon registration (Required)
AGENT_KAS_ADDRESS=... # The Kubernetes Agent Server address. Defaults to `wss://kas.gitlab.com` and should work for the `gitlab.com` instance.
AGENT_VERSION=... # The agent version to install. Defaults to `14.7.0`.
NAMESPACE=... # The kubernetes namespace to install the agent to. Defaults to `gitlab`.
```

After the manifest file has been generated (and modified if necessary, such as to add proxy configurations), run `make agent` to deploy it.

GitLab Runner Manifests 
-----------------------

The GitLab Runner Manifests when deployed through the agent requires certain secrets to be deployed on the cluster for the runner to successfully register and use the MinIO Cache.

To simplify this process, the `agent-runner-secrets` make target was created which deploys the necessary secrets. This make target requires the following environment variables to be set:

```console
MINIO_USERNAME=... # The MinIO Access Key for GitLab Runners
MINIO_PASSWORD=... # The MinIO Secret Key for GitLab Runners
TOKEN=... # The runner registration token.
NAMESPACE=... # The kubernetes namespace to install the secrets to. Defaults to `gitlab`.
```