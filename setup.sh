#!/bin/bash
set -e

# make sure submodules are pulled down too
git submodule update --init --recursive

# Make sure rcm's config is set up
ln -s $HOME/.dotfiles/rcrc $HOME/.rcrc || true

# set up symlinks
rcup 
