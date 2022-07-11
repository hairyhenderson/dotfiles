# convenience functions to insert/append to the path, while not polluting it with
# nonexistant paths on systems where they don't exist
function pathinsert () {
  if [[ -d $1 ]]; then
    export PATH="$1:$PATH"
  fi
}

function pathappend () {
  if [[ -d $1 ]]; then
    export PATH="$PATH:$1"
  fi
}

if [ -d "$HOME/gocode" ]; then
  export GOPATH="$HOME/gocode"
else
  export GOPATH="$HOME/go"
fi

if [ -x "/usr/libexec/path_helper" ]; then
  eval "$(/usr/libexec/path_helper)"
else
  export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
fi

if [ -x /opt/homebrew/bin/brew ]; then
  export HOMEBREW_PREFIX=/opt/homebrew
else
  export HOMEBREW_PREFIX=$(brew config 2>/dev/null | grep ^HOMEBREW_PREFIX | cut -f2 -d\ )
fi

pathappend "$HOME/.rvm/bin"
pathinsert "$HOMEBREW_PREFIX/bin"
pathinsert "$HOMEBREW_PREFIX/sbin"
pathappend "$HOMEBREW_PREFIX/opt/go/libexec/bin"
pathappend "/usr/local/go/libexec/bin"
pathappend "$HOMEBREW_PREFIX/opt/mysql-client@5.7/bin"
pathinsert "$HOME/bin"
pathinsert "$HOME/Library/Python/2.7/bin"
pathinsert "$HOMEBREW_PREFIX/opt/python/libexec/bin"
pathinsert "$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin"
pathinsert "$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin"
pathinsert "$HOMEBREW_PREFIX/opt/gettext/bin"
pathinsert "/usr/local/go/bin"
pathinsert "$HOME/bin/docker"
pathinsert "$HOME/bin/packer"
pathinsert "$HOME/bin/terraform"
pathinsert "$HOME/bin/google-cloud-sdk/bin"
pathinsert "$GOPATH/bin"
pathinsert "$HOME/bin"

export EDITOR="vim"

export DOCKER_BUILDKIT=1

export EJSON_KEYDIR=/keybase/private/dhenderson/ejson

# Set this to true to profile the start
PROFILE_STARTUP=false
if $PROFILE_STARTUP; then
  zmodload zsh/datetime
  setopt promptsubst
  PS4='+$EPOCHREALTIME %N:%i> '
  exec 3>&2 2>/tmp/startlog.$$
  setopt xtrace prompt_subst
fi

OS=$(uname)
if [[ ${OS} == 'Darwin' ]]; then
  # show/hide hidden files in finder
  alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
  alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

  # Some GNU-compatability aliases
  # gfind is installed by the `findutils` homebrew package
  alias find=gfind
  alias mktemp=gmktemp

  # grealpath is installed by the `coreutils` homebrew package
  export DOTFILES_HOME=$(dirname `grealpath ~/.zshrc`)
else
  export DOTFILES_HOME=$(dirname `realpath ~/.zshrc`)
fi

if [ -f "$DOTFILES_HOME/.env" ]; then
  source $DOTFILES_HOME/.env
fi

alias dockviz="docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock nate/dockviz"

alias ip='ip --color'
alias ipb='ip --color --brief'

if [ -d ~/.nvm ]; then
  export NVM_DIR=~/.nvm
  local nvm_script
  if [ -f $NVM_DIR/nvm.sh ]; then
    nvm_script=$NVM_DIR/nvm.sh
  elif [ -f $HOMEBREW_PREFIX/opt/nvm/nvm.sh ]; then
    nvm_script=$HOMEBREW_PREFIX/opt/nvm/nvm.sh
  elif [ -x "$(which brew)" ]; then
    nvm_script=$(brew --prefix nvm)/nvm.sh
  fi
  source $nvm_script
fi

# oh-my-zsh setup
COMPLETION_WAITING_DOTS="true"

export ZSH="$DOTFILES_HOME/oh-my-zsh"
export ZSH_CUSTOM="$DOTFILES_HOME"
ZSH_THEME="dave"

plugins=(
  git
  docker
  node
  kubectl
  kubectx
  fzf
)

source $ZSH/oh-my-zsh.sh

# installed by the `awscli` homebrew package
if [ -f $HOMEBREW_PREFIX/share/zsh/site-functions/_aws ]; then
  source $HOMEBREW_PREFIX/share/zsh/site-functions/_aws
fi

if [ -d ~/.nvm ]; then
  # call nvm use automatically whenever you enter a directory that contains an .nvmrc file 
  autoload -U add-zsh-hook
  load-nvmrc() {
    if [[ -f .nvmrc && -r .nvmrc ]]; then
      nvm use
    elif [[ -f package.json ]]; then
      local nvmver=$(nvm version)
      local nvmver_node=$(nvm version node)
      if [[ $nvmver != $nvmver_node  ]]; then
        echo "No .nvmrc found - using Node.js ${nvmver_node}..."
        nvm use node
      fi
    fi
  }
  add-zsh-hook chpwd load-nvmrc
fi

if $PROFILE_STARTUP; then
  unsetopt xtrace
  # restore stderr to the value saved in FD 3
  exec 2>&3 3>&-
fi

alias ls='ls --color=auto -G'

if [ -d ~/bin/google-cloud-sdk/ ]; then
  source ~/bin/google-cloud-sdk/completion.zsh.inc
  source ~/bin/google-cloud-sdk/path.zsh.inc

  export USE_GKE_GCLOUD_AUTH_PLUGIN=True

  #eval $(minikube completion zsh)
elif [ -d $HOMEBREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/ ]; then
  source $HOMEBREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc
  source $HOMEBREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc

  #eval $(minikube completion zsh)
fi

for cmd in kubectl helm; do
  (( $+commands[$cmd] )) && source <($cmd completion zsh)
done

export USE_GKE_GCLOUD_AUTH_PLUGIN=True

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Config history late so oh-my-zsh doesn't get in the way
export HISTFILE=~/.zsh_history
export HISTSIZE=999999999
export SAVEHIST=$HISTSIZE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_FCNTL_LOCK
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY

setopt no_autocd
setopt no_autopushd

if [ -e /usr/local/bin/code ]; then
  EXTFILE=${DOTFILES_HOME}/vscode/install_extensions.sh
  echo '#!/bin/sh' > ${EXTFILE}
  chmod 755 ${EXTFILE}
  code --list-extensions | xargs -L 1 echo code --install-extension >> ${EXTFILE}
fi

############## BEGIN LOKI-SHELL #####################

# NOTE when changing the Loki URL, also remember to change the promtail config: ~/.loki-shell/config/promtail-logging-config.yaml

# disabled for now - logcli output is ugly
#export LOKI_URL="http://localhost:4100"

#[ -f ~/.loki-shell/shell/loki-shell.zsh ] && source ~/.loki-shell/shell/loki-shell.zsh

############## END LOKI-SHELL   #####################
