# Demo

In this example, we'll train a PyTorch classification model and then create a KFData inference pipeline for it with Kubeflow Pipelines and Pachyderm.

Requires:
- [docker](https://docs.docker.com/engine/install/)
- [testfaster](https://testfaster.ci)

## Train model

```
(cd example; ./train.sh)
```

Will generate `example/model/`.

