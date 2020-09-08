# kfdata
Prototype implementation of KFData proposal - see [pachdm.com/kfdata](https://pachdm.com/kfdata)

# Design

![KFData design](kfdata-design.png)

# User stories

1. User attaches dataset as reader to a pipeline spec, gets dataset env vars auto-populated (can use built-in Minio for this without Pachyderm)
2. Pachyderm triggers an incremental (per-datum) pipeline run in KFData, gets env vars with capability-like access to subset of data to be processed


# Discussion

How does dataset get specified in a pipeline spec?

KFP pipelines typically specify data as pipeline parameters, normally a reference to a GCS bucket (which, by the way fails out of the box on Kubeflow).

So, to get us started let's figure out how we'll specify datasets to pipeline components...

Well, KFP pipelines specify [InputPath and OutputPath params](https://github.com/kubeflow/pipelines/blob/master/samples/tutorials/Data%20passing%20in%20python%20components.ipynb) to `func_to_container_op` methods.
It then seems that it's KFP's job to read/write files to object storage.
So that's fine for passing data between pipeline steps, but how about getting data into the pipeline in the first place?

Hmm, I'm having trouble finding a sensible KFP example!

[This](https://github.com/kubeflow/examples/blob/master/mnist/mnist_vanilla_k8s.ipynb) is the kind of thing I want, but that doesn't use KFP.

[This](https://github.com/kubeflow/examples/tree/master/financial_time_series) might work, but is quite GCP-specific.

The typical Iris sample uses TFX, and I sorta don't want to go down the TFX rabbithole right now. (How does TFX/TFJob get work done on Kubeflow? Is it by starting its own pods or something? That will make our proposal hard.)

I want something which is "typical", in the expected sense that:
* It uses object storage and InputPath/OutputPath parameters (not PVs like the [Canonical example](https://ubuntu.com/blog/data-science-workflows-on-kubernetes-with-kubeflow-pipelines-part-2)).
* It's not tied to GCP (I'm not using GCP, I'm using an "on-prem" Kubeflow with local minio, so the [Cisco example](https://github.com/kubeflow/examples/blob/master/mnist/mnist_vanilla_k8s.ipynb) but it doesn't use KFP).
* It uses real input data. A lot of the ML ones don't use data at all really, they just use toy datasets e.g. Iris.

Financial time series might be the best bet. Let's see if we can get it to run without GCP.

It does:
* Define a [Kubeflow pipeline](https://github.com/kubeflow/examples/blob/d93c18f/financial_time_series/tensorflow_model/ml_pipeline.py)
* Ingest data from [a GCS bucket](https://github.com/kubeflow/examples/blob/d93c18f/financial_time_series/tensorflow_model/run_train.py#L86)

It doesn't:
* Use `func_to_container_op`, so there's manual docker build steps

Hmm: [this](https://github.com/kubeflow/examples/pull/669/files) looks promising... but it's documented as not working.

Maybe extending the "Data passing in python components" example to read input data from somewhere...

So let's make our own example.

* [pytorch text model](https://pytorch.org/tutorials/beginner/text_sentiment_ngrams_tutorial.html)
* inference pipeline which just does sentiment analysis on strings of text
* kfp `func_to_container_op` with InputPath and OutputPath annotations, in a python script we can run easily to test KFData
* make it use minio on the kubeflow cluster

Does this help us decide how to attach Datasets as readers/writers to Pipelines, and DatasetSpec to a pipeline run creation request?

Well, for one thing they should be somewhat orthogonal to InputPath and OutputPath.

If KFP itself has code to read and write objects to/from object storage (which "data passing in python components" suggests), we should provide a way to connect Datasets to `{Input,Output}Path`s somehow... on the "outside" of a pipeline.

So Datasets should be able to connect to the "outside ports" of a KFP.
How we provide Dataset attachment to pipeline specs depends on the specifics of how the `{Input,Output}Path` internals work.

Next step: go read the code for `{Input,Output}Path`.

Here's one idea: the convention seems to be that you pass `gs://foo` paths as pipeline parameters, and it's up to the pipeline to list objects and open one and feed it to further pipeline steps as InputPath and InputTextFile types etc (TODO: verify this - if KFP/Argo uses object storage for data passing, can't it read from it for pipeline inputs too?).

We could invent a new convention that a pipeline parameter `kfdata://foo:r` attaches KFData dataset `foo` as a reader, and `kfdata://bar:w` attaches `bar` as a writer, populating the appropriate env vars for, say, an S3 client library.

There could be a corresponding `kfp` Python SDK module which is responsible for implementing the translation as a first pass. It could just go and find the Dataset in the Kubernetes API.

In the future it would be better, of course, if Datasets were a top level object in Kubeflow, creatable/listable in the UI and attachable in the pipeline run builder UI (just like the experiment picker).


# Implementation

* Try using Admission Controllers to minimize changes needed to KFP
  * Create operator for CRDs for Dataset Types, Datasets; admission controller to process compiled Argo pipelines to add env vars as v1
* Likely end up using MLMD
  * Treat each Dataset as an Artifact
* Hopefully reuse work across TFX/KFData efforts
  * We recognize that TFX has some similarities, but don’t want to force users to rewrite their pipelines in TFX DSL to take advantage of KFData
  * NB: added TFX section to [proposal doc](https://docs.google.com/document/d/1ccIM5-khU52HuZKSujRmgDyzxyzJZ6cmI597uqdh-ek/edit)
* On October 14, we’ll aim to bring a POC & demo to this WG
  * Target delivery for inclusion and promotion in next appropriate Kubeflow release -- if the KFP WG is supportive
