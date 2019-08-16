#!/usr/bin/env bash

mkdir nodejs

yarn add \
  --silent \
  --no-lockfile \
  --non-interactive \
  --modules-folder nodejs/node_modules \
  koa \
  koa-route \
  react \
  react-dom \
  react-helmet-async \
  react-router-dom \
  serverless-http \
  styled-components

rm package.json
