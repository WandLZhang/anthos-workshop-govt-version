#!/usr/bin/env bash

# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo "### "
echo "### Deploying government app on central and remote clusters"
echo "### "


# Set vars for DIRs
export BASE_DIR=${BASE_DIR:="${PWD}/.."}
echo "BASE_DIR set to $BASE_DIR"
export ISTIO_CONFIG_DIR="$BASE_DIR/hybrid-multicluster/istio"

# Get Istio ingress gateway Ip addresses from both central and remote clusters
export GWIP_CENTRAL=$(kubectl --context central get -n istio-system service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export GWIP_REMOTE=$(kubectl --context remote get -n istio-system service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Prepare central cluster government manifests
# change context to central cluster
kubectx central
# Prepare the service-entries yaml to add the remote cluster istio ingress gateway IP 
# for all services running in the remote cluster
export pattern='.*- address:.*'
export replace="  - address: "$GWIP_REMOTE""
sed -r -i "s|$pattern|$replace|g" ${ISTIO_CONFIG_DIR}/central/service-entries.yaml

# Create gov2 namespace and enable istioInjection on the namespace
kubectl create namespace gov2
kubectl label namespace gov2 istio-injection=enabled

# Deploy part of government app on central cluster in the namespace gov2
kubectl apply -n gov2  -f ${ISTIO_CONFIG_DIR}/central

# Prepare remote cluster government manifests
# change context to remote cluster
kubectx remote
# Prepare the service-entries yaml to add the remote cluster istio ingress gateway IP 
# for all services running in the remote cluster
export pattern='.*- address:.*'
export replace="  - address: "$GWIP_CENTRAL""
sed -r -i "s|$pattern|$replace|g" ${ISTIO_CONFIG_DIR}/remote/service-entries.yaml

# Create gov2 namespace and enable istioInjection on the namespace
kubectl create namespace gov1
kubectl label namespace gov1 istio-injection=enabled

# Deploy part of government app on central cluster in the namespace gov2
kubectl apply -n gov1  -f ${ISTIO_CONFIG_DIR}/remote
