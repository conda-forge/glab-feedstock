#!/usr/bin/env bash
set -eux

echo "ensuring go version in go.mod:#/go is ${CBC_GO_VERSION}"
GO_MOD_GO_VERSION=$(grep -iE "^go .*$" go.mod)

if [[ "${GO_MOD_GO_VERSION}" == "go ${CBC_GO_VERSION}" ]] ;
then
  echo "OK go version in go.toml and conda_build_config.yaml agree: ${GO_MOD_GO_VERSION}"
else
  echo "ERROR go version unexpcted"
  echo "... please update recipe/conda_build_config.yaml#/go_cgo_compiler_version"
  echo "    to match ${GO_MOD_GO_VERSION}"
  exit 2
fi
