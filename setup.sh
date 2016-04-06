#!/bin/bash
set -e

# make sure submodules are pulled down too
git submodule update --init --recursive

# set up symlinks
rcup
