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
pathappend "$HOME/.rvm/bin"
pathappend "/usr/local/opt/go/libexec/bin"
pathappend "/usr/local/go/libexec/bin"
pathinsert "$HOME/bin"
pathinsert "$HOME/Library/Python/2.7/bin"
pathinsert "/usr/local/opt/python/libexec/bin"
pathinsert "/usr/local/opt/coreutils/libexec/gnubin"
pathinsert "/usr/local/opt/gnu-sed/libexec/gnubin"
pathinsert "/usr/local/opt/gettext/bin"
pathinsert "/usr/local/go/bin"
pathinsert "$HOME/bin/docker"
pathinsert "$HOME/bin/packer"
pathinsert "$HOME/bin/terraform"
pathinsert "$HOME/bin/google-cloud-sdk/bin"
pathinsert "$GOPATH/bin"

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
  elif [ -f /usr/local/opt/nvm/nvm.sh ]; then
    nvm_script=/usr/local/opt/nvm/nvm.sh
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
)

source $ZSH/oh-my-zsh.sh

# installed by the `awscli` homebrew package
if [ -f /usr/local/share/zsh/site-functions/_aws ]; then
  source /usr/local/share/zsh/site-functions/_aws
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

  #eval $(minikube completion zsh)
elif [ -d /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/ ]; then
  source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc
  source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc

  #eval $(minikube completion zsh)
fi

for cmd in kubectl helm; do
  (( $+commands[$cmd] )) && source <($cmd completion zsh)
done

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

if [ -e /usr/local/bin/code ]; then
  EXTFILE=${DOTFILES_HOME}/vscode/install_extensions.sh
  echo '#!/bin/sh' > ${EXTFILE}
  chmod 755 ${EXTFILE}
  code --list-extensions | xargs -L 1 echo code --install-extension >> ${EXTFILE}
fi
