#!/bin/bash
set -euo pipefail
testctl get --config .testfaster.yml
export KUBECONFIG=$(pwd)/kubeconfig
export VERSION="$(git rev-parse HEAD)"
export IMG=ghcr.io/pachyderm/kfdata:$VERSION
(
    cd src/kfdata
    make docker-build docker-push
    kubectl create namespace kfdata-system
    make deploy
)
