#!/bin/bash
set -euo pipefail
testctl get --config .testfaster.yml
export KUBECONFIG=$(pwd)/kubeconfig
export VERSION="$(git rev-parse HEAD)"

# NB: taking different approach for now, using dataset-lifecycle-framework...)
#export IMG=ghcr.io/pachyderm/kfdata:$VERSION
#(
#    cd src/kfdata
#    make docker-build docker-push
#    kubectl create namespace kfdata-system
#    make deploy
#)

# NB: Following line is moved into .testfaster.yml
#(cd dataset-lifecycle-framework; make minikube-install)

(cd dataset-lifecycle-framework/examples/noobaa; ./noobaa_install.sh)
