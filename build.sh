#!/usr/bin/env bash

script_path="$(cd $(dirname "$0"); pwd)"

echo ".. Getting submodules"

rm -rf $script_path/lib/submodule/utPLSQL

# get utPLSQL submodule
git clone --branch v3.1.3 --depth 1 https://github.com/utPLSQL/utPLSQL.git $script_path/lib/submodule/utPLSQL
rm -rf $script_path/lib/submodule/utPLSQL/.git*