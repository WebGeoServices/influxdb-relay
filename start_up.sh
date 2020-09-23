#!/usr/bin/env bash

# Create config file
./render_toml.sh

# Start relay
exec influxdb-relay -config relay.toml