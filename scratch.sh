# Check Minikube Status
host_status=$(minikube status -o json | jq -r '.Host')
kubelet_status=$(minikube status -o json | jq -r '.Kubelet')
apiserver_status=$(minikube status -o json | jq -r '.APIServer')
kubeconfig_status=$(minikube status -o json | jq -r '.Kubeconfig')
if [[ "$host_status" == "Stopped" && "$kubelet_status" == "Stopped" && "$apiserver_status" == "Stopped" && "$kubeconfig_status" == "Stopped" ]]; then
    echo "Minikube is not running.\nRun "minikube start" and then re-rerun the script." >&2
    exit 1
fi

export WORKDIR="/Users/maxwinslow/dev/sandbox-vault/vltrneetus/tls-install/"




# # If not already started
# minikube start
# minikube status

# rm -rf certs/* cluster-keys.json

# kubectl create ns vault
# kubectl config set-context --current --namespace=vault

# export VAULT_K8S_NAMESPACE="vault"
# export VAULT_HELM_RELEASE_NAME="vault" \
# export VAULT_SERVICE_NAME="vault-internal" \
# export K8S_CLUSTER_NAME="cluster.local" \
# export WORKDIR=$(pwd)

# openssl genrsa -out ${WORKDIR}/certs/vault.key 2048                        
# cat > ${WORKDIR}/certs/vault-csr.conf <<EOF
# [req]
# default_bits = 2048
# prompt = no
# encrypt_key = yes
# default_md = sha256
# distinguished_name = kubelet_serving
# req_extensions = v3_req
# [ kubelet_serving ]
# O = system:nodes
# CN = system:node:*.${VAULT_K8S_NAMESPACE}.svc.${K8S_CLUSTER_NAME}
# [ v3_req ]
# basicConstraints = CA:FALSE
# keyUsage = nonRepudiation, digitalSignature, keyEncipherment, dataEncipherment
# extendedKeyUsage = serverAuth, clientAuth
# subjectAltName = @alt_names
# [alt_names]
# DNS.1 = *.${VAULT_SERVICE_NAME}
# DNS.2 = *.${VAULT_SERVICE_NAME}.${VAULT_K8S_NAMESPACE}.svc.${K8S_CLUSTER_NAME}
# DNS.3 = *.${VAULT_K8S_NAMESPACE}
# IP.1 = 127.0.0.1
# EOF

# openssl req -new -key ${WORKDIR}/certs/vault.key -out ${WORKDIR}/certs/vault.csr -config ${WORKDIR}/certs/vault-csr.conf
# openssl req -in ${WORKDIR}/certs/vault.csr -subject -noout

# cat > ${WORKDIR}/certs/csr.yaml <<EOF
# apiVersion: certificates.k8s.io/v1
# kind: CertificateSigningRequest
# metadata:
#    name: vault.svc
# spec:
#    signerName: kubernetes.io/kubelet-serving
#    expirationSeconds: 8640000
#    request: $(cat ${WORKDIR}/certs/vault.csr|base64|tr -d '\n')
#    usages:
#    - digital signature
#    - key encipherment
#    - server auth
# EOF

# # Not deleted with namespace? Handle replace?
# kubectl create -f ${WORKDIR}/certs/csr.yaml
# kubectl get csr vault.svc
# kubectl certificate approve vault.svc
# kubectl get csr vault.svc

# kubectl get csr vault.svc -o jsonpath='{.status.certificate}' | openssl base64 -d -A -out ${WORKDIR}/certs/vault.crt
# openssl x509 -in ${WORKDIR}/certs/vault.crt  -noout -subject -issuer

# kubectl config view \
# --raw \
# --minify \
# --flatten \
# -o jsonpath='{.clusters[].cluster.certificate-authority-data}' \
# | base64 -d > ${WORKDIR}/certs/vault.ca
# openssl x509 -in ${WORKDIR}/certs/vault.ca  -noout -subject -issuer

# kubectl create secret generic vault-ha-tls \
#    -n $VAULT_K8S_NAMESPACE \
#    --from-file=vault.key=${WORKDIR}/certs/vault.key \
#    --from-file=vault.crt=${WORKDIR}/certs/vault.crt \
#    --from-file=vault.ca=${WORKDIR}/certs/vault.ca

# kubectl get secret vault-ha-tls

# cat > ${WORKDIR}/overrides.yaml <<EOF
# global:
#    enabled: true
#    tlsDisable: false
# injector:
#    enabled: true
# server:
#    extraEnvironmentVars:
#       VAULT_CACERT: /vault/userconfig/vault-ha-tls/vault.ca
#       VAULT_TLSCERT: /vault/userconfig/vault-ha-tls/vault.crt
#       VAULT_TLSKEY: /vault/userconfig/vault-ha-tls/vault.key
#    volumes:
#       - name: userconfig-vault-ha-tls
#         secret:
#          defaultMode: 420
#          secretName: vault-ha-tls
#    volumeMounts:
#       - mountPath: /vault/userconfig/vault-ha-tls
#         name: userconfig-vault-ha-tls
#         readOnly: true
#    standalone:
#       enabled: false
#    affinity: ""
#    ha:
#       enabled: true
#       replicas: 3
#       raft:
#          enabled: true
#          setNodeId: true
#          config: |
#             ui = true
#             listener "tcp" {
#                tls_disable = 0
#                address = "[::]:8200"
#                cluster_address = "[::]:8201"
#                tls_cert_file = "/vault/userconfig/vault-ha-tls/vault.crt"
#                tls_key_file  = "/vault/userconfig/vault-ha-tls/vault.key"
#                tls_client_ca_file = "/vault/userconfig/vault-ha-tls/vault.ca"
#             }
#             storage "raft" {
#                path = "/vault/data"
#             }
#             disable_mlock = true
#             service_registration "kubernetes" {}
# EOF

# helm install -n $VAULT_K8S_NAMESPACE $VAULT_HELM_RELEASE_NAME hashicorp/vault -f ${WORKDIR}/overrides.yaml

#  kubectl exec -n $VAULT_K8S_NAMESPACE vault-0 -- vault operator init \
#     -key-shares=1 \
#     -key-threshold=1 \
#     -format=json > ${WORKDIR}/cluster-keys.json

# VAULT_UNSEAL_KEY=$(jq -r ".unseal_keys_b64[]" ${WORKDIR}/cluster-keys.json)

# kubectl exec -n $VAULT_K8S_NAMESPACE vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY

# kubectl exec -n $VAULT_K8S_NAMESPACE -it vault-1 -- /bin/sh

# vault operator raft join -address=https://vault-1.vault-internal:8200 -leader-ca-cert="$(cat /vault/userconfig/vault-ha-tls/vault.ca)" -leader-client-cert="$(cat /vault/userconfig/vault-ha-tls/vault.crt)" -leader-client-key="$(cat /vault/userconfig/vault-ha-tls/vault.key)" https://vault-0.vault-internal:8200

# exit

# kubectl exec -n $VAULT_K8S_NAMESPACE -ti vault-1 -- vault operator unseal $VAULT_UNSEAL_KEY

# kubectl exec -n $VAULT_K8S_NAMESPACE -ti vault-1 -- vault status

# kubectl exec -n $VAULT_K8S_NAMESPACE -it vault-2 -- /bin/sh

# vault operator raft join -address=https://vault-2.vault-internal:8200 -leader-ca-cert="$(cat /vault/userconfig/vault-ha-tls/vault.ca)" -leader-client-cert="$(cat /vault/userconfig/vault-ha-tls/vault.crt)" -leader-client-key="$(cat /vault/userconfig/vault-ha-tls/vault.key)" https://vault-0.vault-internal:8200

# exit

# kubectl exec -n $VAULT_K8S_NAMESPACE -ti vault-2 -- vault operator unseal $VAULT_UNSEAL_KEY

# kubectl exec -n $VAULT_K8S_NAMESPACE -ti vault-2 -- vault status

# export CLUSTER_ROOT_TOKEN=$(cat ${WORKDIR}/cluster-keys.json | jq -r ".root_token")

# kubectl exec -n $VAULT_K8S_NAMESPACE vault-0 -- vault login $CLUSTER_ROOT_TOKEN

# kubectl exec -n $VAULT_K8S_NAMESPACE vault-0 -- vault operator raft list-peers

# kubectl exec -n $VAULT_K8S_NAMESPACE vault-0 -- vault status

# kubectl exec -n $VAULT_K8S_NAMESPACE -it vault-0 -- /bin/sh

# vault secrets enable -path=secret kv-v2

# vault kv put secret/max username="maxy" password="winz"

# vault kv get secret/max

# exit

# # One terminal
# kubectl -n vault port-forward service/vault 8200:8200


# export CLUSTER_ROOT_TOKEN=$(cat ${WORKDIR}/cluster-keys.json | jq -r ".root_token")

# curl --cacert $WORKDIR/certs/vault.ca \
#    --header "X-Vault-Token: $CLUSTER_ROOT_TOKEN" \
#    https://127.0.0.1:8200/v1/secret/data/max | jq .


# kubectl exec -n $VAULT_K8S_NAMESPACE -it vault-0 -- /bin/sh

# vault auth enable kubernetes

# vault write auth/kubernetes/config \
#       kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"

# vault policy write internal-app - <<EOF
# path "*" {
#    capabilities = ["read"]
# }
# EOF

# vault write auth/kubernetes/role/internal-app \
#       bound_service_account_names=internal-app \
#       bound_service_account_namespaces=vault \
#       policies=internal-app \
#       ttl=24h

# exit

# kubectl create sa internal-app

# # k create deploy nginx --image nginx --dry-run=client -o yaml > nginx.yaml

# # add service account

# # Create the secret from the CA file
# kubectl create secret generic vault-ca \
#   --from-file="${WORKDIR}/certs/vault.ca"
# kubectl get secret vault-ca


# # Give nginx pod a name
# kubectl apply -f nginx.yaml

# kubectl exec -it nginx-7596bb4775-jxfbt --container nginx -- cat /vault/secrets/database-config.txt


# helm uninstall vault
# kubectl delete namespace vault
# kubectl delete csr vault.svc



