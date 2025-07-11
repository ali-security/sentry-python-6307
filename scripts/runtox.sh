#!/bin/bash

# Usage: sh scripts/runtox.sh py3.7 <pytest-args>
# Runs all environments with substring py3.7 and the given arguments for pytest

set -ex

if [ -n "$TOXPATH" ]; then
    true
elif which tox &> /dev/null; then
    TOXPATH=tox
else
    TOXPATH=./.venv/bin/tox
fi

searchstring="$1"

export TOX_PARALLEL_NO_SPINNER=1
PIP_INDEX_URL='https://:2023-03-16T15:53:34.069817Z@time-machines-pypi.sealsecurity.io/' exec $TOXPATH -vv -p auto -e "$($TOXPATH -l | grep "$searchstring" | tr $'\n' ',')" -- "${@:2}"
