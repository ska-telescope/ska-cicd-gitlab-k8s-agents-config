# Prerequisites

You need to have [helm](https://helm.sh/docs/intro/install/) and [vault cli](https://learn.hashicorp.com/tutorials/vault/getting-started-install) installed.

# Generate vault-agent manifests

Bellow is the command to generate the manifest for the vault-agent.

We need to pass some parameters:


| <!-- -->    | <!-- -->    |
|-------------|-------------|
| helm release name| vault
| namespace | vault
| vault address | https://vault-test-1.skao.int
| authentication path | auth/stfc



```sh
helm template --debug vault -n vault hashicorp/vault --set injector.externalVaultAddr="https://vault-test-1.skao.int" --set injector.authPath="auth/stfc" > vault-agent.yaml
```

You can find more about the helm chart [here](https://github.com/hashicorp/vault-helm).

# Push vault-agent configurations to server 
The deployment of the agent will generate secrets in the provided namespace.
We need to create/update the configurations between the vault agent and server to have connection.


```sh
VAULT_HELM_SECRET_NAME=$(kubectl get secrets -n vault --output=json | jq -r '.items[].metadata | select(.name|startswith("vault-auth-token-")).name')
TOKEN_REVIEW_JWT=$(kubectl get secret $VAULT_HELM_SECRET_NAME -n vault --output='go-template={{ .data.token }}' | base64 --decode)
KUBE_CA_CERT=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)
KUBE_HOST=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')


vault write auth/stfc/config \
        token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
        kubernetes_host="$KUBE_HOST" \
        kubernetes_ca_cert="$KUBE_CA_CERT" \
        issuer="https://kubernetes.default.svc.cluster.local"
```

# Test connection

You can test the connection by deploying a test pod (to any namespace) with some vault annotations. 

```yaml
annotations:
    vault.hashicorp.com/agent-inject: 'true'
    vault.hashicorp.com/role: 'role-name'
    vault.hashicorp.com/agent-inject-secret-{filename}: 'secrets-path-in-server'
```

Then after creating you should see the secret inside de pod in the path:

- /vault/secrets/{filename}

