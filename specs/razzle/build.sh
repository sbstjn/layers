#!/usr/bin/env bash

mkdir nodejs

yarn add \
  --silent \
  --no-lockfile \
  --non-interactive \
  --modules-folder nodejs/node_modules \
  aws-serverless-express \
  express \
  react \
  react-dom \
  react-router-dom \
  styled-components

rm package.json
