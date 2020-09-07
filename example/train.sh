#!/bin/bash
docker build -t pytorch-example .
mkdir -p output
docker run -v $(pwd)/output:/app/output -ti pytorch-example bash -c \
    "cd /app; python text_sentiment_ngrams_tutorial.py"
