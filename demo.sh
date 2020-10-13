#!/bin/bash

set -xeuo pipefail

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
 cd pachyderm/examples/kubeflow/mnist
 ./build.sh
)

set +x

echo
echo
echo
echo "Now run:"
echo "cd pach-example/pachyderm/examples/kubeflow/mnist"
echo "curl -O https://storage.googleapis.com/tensorflow/tf-keras-datasets/mnist.npz"
echo "pachctl create repo input-repo"
echo "pachctl put file input-repo@master:/mnist.npz -f mnist.npz"
echo "pachctl create pipeline -f pipeline.yaml"
echo "pachctl list pipeline"
echo "testctl ip # <- then go to the web UI, observe one pipeline run happens"
echo "curl -O https://storage.googleapis.com/tensorflow/tf-keras-datasets/fashion_mnist.npz"
echo "pachctl put file input-repo@master:/fashion_mnist.npz -f fashion_mnist.npz"
echo "# now look at the web ui, observe that only the incremental data was visible to the job"
echo "# and yet, both data files are stored in pachyderm along with full version history and provenance:"
echo "pachctl list file input-repo@master"
