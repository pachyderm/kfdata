#!/bin/bash

set -euo pipefail

(cd pach-example/pachyderm
 make docker-build
)

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
#(cd dataset-lifecycle-framework/examples/noobaa; ./noobaa_install.sh)

# XXX assumes pachctl is installed, and will use configured $KUBECONFIG
# TODO: install pachctl locally if not existing

# XXX workaround 'connected to the wrong cluster' from running twice against different clusters
if [ -f ~/.pachyderm/config.json ]; then
    mv ~/.pachyderm/config.json ~/.pachyderm/config.json.backup-$(date +%s)
fi

(cd pach-example/pachyderm
 for X in worker pachd; do
     echo "Copying pachyderm/$X:local to kube"
     docker save pachyderm/$X:local |gzip | pv | testctl ssh --tty=false -- sh -c 'gzip -d | docker load'
 done
 make launch-dev
)

(cd pach-example
 curl -O https://storage.googleapis.com/tensorflow/tf-keras-datasets/mnist.npz
 pachctl create repo input-repo
 pachctl put file input-repo@master:/mnist.npz -f mnist.npz
 cd pachyderm/examples/kubeflow/mnist
 sleep 10
 pachctl create pipeline -f pipeline.yaml
 sleep 10
 pachctl list pipeline
 export PIPELINE_POD=$(kubectl get pods --namespace default -l "app=pipeline-mnist-v1" -o jsonpath="{.items[0].metadata.name}")
 export PACHD_POD=$(kubectl get pods --namespace default -l "app=pachd" -o jsonpath="{.items[0].metadata.name}")
 echo PIPELINE_POD=$PIPELINE_POD
 echo PACHD_POD=$PACHD_POD
 kubectl logs $PIPELINE_POD storage |grep OnCreate
)
