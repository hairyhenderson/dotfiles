#!/bin/bash
set -e

# make sure submodules are pulled down too
pushd $HOME/.dotfiles
git submodule update --init --recursive
popd

# Make sure rcm's config is set up
ln -s $HOME/.dotfiles/.rcrc $HOME/.rcrc || true

# set up symlinks
cd $HOME
rcup 

# Other setup
rm $HOME/Library/Application\ Support/Code/User/settings.json
ln $HOME/.dotfiles/vscode/settings.json $HOME/Library/Application\ Support/Code/User/settings.json
