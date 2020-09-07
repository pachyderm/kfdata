#!/bin/bash
docker build -t pytorch-example .
mkdir -p output/model
docker run -v $(pwd)/output:/app/output -ti pytorch-example python /app/text_sentiment_ngrams_tutorial.py
