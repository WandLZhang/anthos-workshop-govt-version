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
echo "### Migrate all government to central cluster"
echo "### "

# Set vars for DIRs
export ISTIO_VERSION=1.1.15
export WORK_DIR=${WORK_DIR:="${PWD}/workdir"}
export ISTIO_DIR=$WORK_DIR/istio-$ISTIO_VERSION
export BASE_DIR=${BASE_DIR:="${PWD}/.."}
echo "BASE_DIR set to $BASE_DIR"
export ISTIO_CONFIG_DIR="$BASE_DIR/hybrid-multicluster/istio"

# Install all of the deployments, services and necessary serviceentries on central cluster
# The following folder contains 
# - All of the deployments for government app
# - Correct ENV values for deployments to point to vaious microservices
# - All of the services for government app
# - A service entry required for currency service to function

kubectx central
kubectl apply -n gov2  -f ${ISTIO_CONFIG_DIR}/government 
kubectl delete -n gov2 -f ${ISTIO_CONFIG_DIR}/central/service-entries.yaml

# Delete remaining Government workloads, services, serviceentries and namespace gov1 from remote cluster
kubectx remote
kubectl delete -n gov1  -f ${ISTIO_CONFIG_DIR}/remote
