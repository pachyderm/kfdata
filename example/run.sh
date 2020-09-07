#!/bin/bash
docker build -t pytorch-example .
docker run -ti pytorch-example python /app/text_sentiment_ngrams_tutorial.py
