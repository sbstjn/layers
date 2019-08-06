#!/usr/bin/env bash

mkdir nodejs

yarn add \
  --silent \
  --no-lockfile \
  --non-interactive \
  --modules-folder nodejs/node_modules \
  aws-serverless-express \
  express \
  jsonwebtoken \
  react \
  react-dom \
  react-helmet \
  react-router-dom \
  request \
  request-promise \
  styled-components

rm package.json
