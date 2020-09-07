# kfdata
Prototype implementation of KFData proposal - see [pachdm.com/kfdata](https://pachdm.com/kfdata)

# Design

![KFData design](kfdata-design.png)

# User stories

1. User attaches dataset as reader to a pipeline spec, gets dataset env vars auto-populated
2. Pachyderm triggers an incremental (per-datum) pipeline run in KFData, gets env vars with capability-like access to subset of data to be processed

# Implementation

* Try using Admission Controllers to minimize changes needed to KFP
  * Create operator for CRDs for Dataset Types, Datasets; admission controller to process compiled Argo pipelines to add env vars as v1
* Likely end up using MLMD
  * Treat each Dataset as an Artifact
* Hopefully reuse work across TFX/KFData efforts
  * We recognize that TFX has some similarities, but don’t want to force users to rewrite their pipelines in TFX DSL to take advantage of KFData
  * NB: added TFX section to [proposal doc](https://docs.google.com/document/d/1ccIM5-khU52HuZKSujRmgDyzxyzJZ6cmI597uqdh-ek/edit)
* In 4-6 weeks, we’ll bring a POC & demo to this WG
  * Target delivery for inclusion and promotion in Kubeflow 1.2 -- if the KFP WG is supportive
