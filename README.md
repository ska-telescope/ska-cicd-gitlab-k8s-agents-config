SKA CICD Gitlab K8s Agents Config
=================================

This repository stores the Gitlab K8s Agents configuration files, which connects the Kubernetes clusters infrastructures with Gitlab and allows the respective KUBECONFIG files to be injected into the pipelines.

Adding and configuring new agents
---------------------------------

To add new agents, a configuration file must be created in the following location in this repository: `.gitlab/agents/<agent-name>/config.yaml`. After this file is added, the agent can be registered in the `Kubernetes clusters` page under `Infrastructure` on the side panel of this repository.

After the agent is registered, a token will be displayed with instructions on how to install the agent on the target Kubernetes cluster.

For more information, see the [Gitlab documentation](https://docs.gitlab.com/ee/user/clusters/agent/repository.html#agent-configuration-repository) on how to configure the agent repository.
