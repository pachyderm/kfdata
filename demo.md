# Demo

In this example, we'll train a PyTorch classification model and then create a KFData inference pipeline for it with Kubeflow Pipelines and Pachyderm.

Requires:
- [docker](https://docs.docker.com/engine/install/)
- [testfaster](https://testfaster.ci)

## Get demo cluster
```
(
    cd example
    testfaster get
    export KUBECONFIG=$(pwd)/kubeconfig
)
```

## Train model

```
(
    cd example
    ./train.sh
)
```

Will generate `example/model.pth`.

## Deploy pipeline

TODO

```
(
    cd example
    testfaster get
    export KUBECONFIG=$(pwd)/kubeconfig

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
)
```

