#!/bin/bash
set -e

# make sure submodules are pulled down too
pushd $HOME/.dotfiles
git submodule update --init --recursive
popd

# set up symlinks
function link () {
  echo "Linking $HOME/.dotfiles/$1 to $HOME/.$1..."
  ln -fs $HOME/.dotfiles/$1 $HOME/.$1
}

link zshrc
link vimrc
link vim

# macOS-specific setup
if [ $(uname -o) = "Darwin" ]; then
  link vscode

  rm -f $HOME/Library/Application\ Support/Code/User/settings.json
  ln $HOME/.dotfiles/vscode/settings.json $HOME/Library/Application\ Support/Code/User/settings.json

  if [[ -d $HOME/Library/Application\ Support/iTerm2/DynamicProfiles ]]; then
    rm -rf $HOME/Library/Application\ Support/iTerm2/DynamicProfiles
  fi

  ln -s $HOME/.dotfiles/iTerm2/DynamicProfiles $HOME/Library/Application\ Support/iTerm2/DynamicProfiles
fi
