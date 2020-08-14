#!/usr/bin/env bash

function render_template() {
  eval "echo \"$(cat $1)\""
}

echo "#### Creating ./relay.toml from template ./relay.toml.tmpl"
render_template relay.toml.tmpl > ./relay.toml
