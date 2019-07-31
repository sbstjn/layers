#!/usr/bin/env bash

mkdir nodejs

yarn add \
  --silent \
  --no-lockfile \
  --non-interactive \
  --modules-folder nodejs/node_modules \
  aws-serverless-express \
  express

rm package.json
