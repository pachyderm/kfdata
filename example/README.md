# KFData Demo

In this example, we'll train a PyTorch classification model and then create a KFData inference pipeline for it with Kubeflow Pipelines and Pachyderm.

Requires:
- [docker](https://docs.docker.com/engine/install/)
- [testfaster](https://testfaster.ci)

## Get demo cluster

You'll need a [testfaster account](https://testfaster.ci/login), then get your [access token](https://testfaster.ci/access_token).

```
testctl login --token "<your token>"
testctl get # TODO make this notice ../.testfaster.yml
export KUBECONFIG=$(pwd)/kubeconfig
```

This cluster has Kubeflow 1.1 and Pachyderm 1.11 [preinstalled](../.testfaster.yml) on it.

## Deploy KFData to cluster

TODO (something like ../test.sh)

```
./build-and-deploy-kfdata.sh
```

## Train model

```
./train.sh
```

Will generate `example/output/model.pth`.

## Deploy pipeline

TODO

```
# Uploads the model we trained
./push-model-to-minio.sh

# Deploy the kfp pipeline that will do inference on new data
# TODO: how does kfp library connect to kubeflow cluster?
python inference_pipeline.py

# Push some data and see a Kubeflow pipeline triggered
./inject-data.sh

# Push some more data and see a Kubeflow pipeline triggered with only the
# incremental changes
./inject-more-data.sh
```

