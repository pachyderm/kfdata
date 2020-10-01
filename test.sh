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
#(cd dataset-lifecycle-framework/examples/noobaa; ./noobaa_install.sh)

# XXX assumes pachctl is installed, and will use configured $KUBECONFIG
# TODO: install pachctl locally if not existing

# XXX workaround 'connected to the wrong cluster' from running twice against different clusters
if [ -f ~/.pachyderm/config.json ]; then
    mv ~/.pachyderm/config.json ~/.pachyderm/config.json.backup-$(date +%s)
fi

(cd pach-example/pachyderm
 make docker-build
 for X in worker pachd; do 
     echo "Copying pachyderm/$X:local to kube"
     docker save pachyderm/$X:local | pv | testctl ssh --tty=false -- docker load
 done
 make launch-dev
)

# TODO remove this line once local pachyderm build is working
exit 0

(cd pach-example
 curl -O https://storage.googleapis.com/tensorflow/tf-keras-datasets/mnist.npz
 pachctl create repo input-repo
 pachctl put file input-repo@master:/mnist.npz -f mnist.npz
 cd pachyderm/examples/kubeflow/mnist
 pachctl create pipeline -f pipeline.yaml
 sleep 10
 pachctl list pipeline
)
