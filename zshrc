# Set this to true (or pass via env) to profile startup
: ${PROFILE_STARTUP:=false}
if $PROFILE_STARTUP; then
  zmodload zsh/datetime
  setopt promptsubst
  PS4='+$EPOCHREALTIME %N:%i> '
  exec 3>&2 2>/tmp/startlog.$$
  setopt xtrace prompt_subst
fi

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
pathinsert "$HOME/go/src/github.com/grafana/hosted-grafana/bin"
pathinsert "$HOMEBREW_PREFIX/opt/util-linux/bin"
#pathinsert "$HOMEBREW_PREFIX/opt/util-linux/sbin"
pathinsert "/usr/local/opt/curl/bin"
pathinsert "$HOME/.local/bin"

export EDITOR="vim"

export DOCKER_BUILDKIT=1

#export EJSON_KEYDIR=/keybase/private/dhenderson/ejson


OS=$(uname)
if [[ ${OS} == 'Darwin' ]]; then
  # show/hide hidden files in finder
  alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
  alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

  # Some GNU-compatability aliases
  # gfind is installed by the `findutils` homebrew package
  alias find=gfind
  alias mktemp=gmktemp

  # tailscale CLI
  alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

  # grealpath is installed by the `coreutils` homebrew package
  export DOTFILES_HOME=$(dirname `grealpath ~/.zshrc`)

  # shortcut to the obsidian vault path
  alias cdobs="cd /Users/hairyhenderson/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/hairyhenderson"
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

  # Locate nvm.sh without sourcing it yet
  if [ -f $NVM_DIR/nvm.sh ]; then
    _nvm_script=$NVM_DIR/nvm.sh
  elif [ -f $HOMEBREW_PREFIX/opt/nvm/nvm.sh ]; then
    _nvm_script=$HOMEBREW_PREFIX/opt/nvm/nvm.sh
  elif [ -x "$(which brew)" ]; then
    _nvm_script=$(brew --prefix nvm)/nvm.sh
  fi

  # Lazy-load: stubs for nvm and common node commands load the real thing on first use
  _nvm_load() {
    unset -f nvm node npm npx yarn _nvm_load
    source "$_nvm_script"
    unset _nvm_script
  }
  nvm()  { _nvm_load; nvm  "$@"; }
  node() { _nvm_load; node "$@"; }
  npm()  { _nvm_load; npm  "$@"; }
  npx()  { _nvm_load; npx  "$@"; }
  yarn() { _nvm_load; yarn "$@"; }
fi

# oh-my-zsh setup
COMPLETION_WAITING_DOTS="true"

export ZSH="$DOTFILES_HOME/oh-my-zsh"
export ZSH_CUSTOM="$DOTFILES_HOME"
ZSH_THEME="dave"

# Speed up compinit by skipping the completion rescan when the dump is <24h old.
# OMZ calls compinit internally; this stub intercepts that call.
ZSH_COMPDUMP="${HOME}/.zcompdump"
compinit() {
  unfunction compinit
  autoload -Uz compinit
  # find returns the file if it's <24h old; empty means stale/missing
  if [[ -f $ZSH_COMPDUMP && -n $(command find "$ZSH_COMPDUMP" -mtime -1 2>/dev/null) ]]; then
    compinit -C -d "$ZSH_COMPDUMP" # dump is fresh: skip rescan
  else
    compinit -d "$ZSH_COMPDUMP"    # dump is stale or missing: full rescan
  fi
}

plugins=(
  git
  docker
  node
  kubectl
  kubectx
  fzf
)

zstyle ':omz:alpha:lib:git' async-prompt no
source $ZSH/oh-my-zsh.sh

# installed by the `awscli` homebrew package
if [ -f $HOMEBREW_PREFIX/share/zsh/site-functions/_aws ]; then
  source $HOMEBREW_PREFIX/share/zsh/site-functions/_aws
fi

# temporary fix for https://forum.cursor.com/t/alt-option-with-right-left-for-cursor-movement-on-terminal/135393/6
bindkey "\e[1;3D" backward-word
bindkey "\e[1;3C" forward-word

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
  if (( $+commands[$cmd] )); then
    cache="${HOME}/.zsh_completion_cache_${cmd}"
    # Regenerate the cached completion if it's missing or older than the binary
    if [[ ! -f $cache || $commands[$cmd] -nt $cache ]]; then
      $cmd completion zsh >| $cache
    fi
    source $cache
  fi
done

export USE_GKE_GCLOUD_AUTH_PLUGIN=True

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# 1Password AWS CLI plugin
if [ -f $HOME/.config/op/plugins.sh ]; then
  # not sourcing for now - it's rare that I actually want to use this profile
  #source $HOME/.config/op/plugins.sh
fi

# for running 'go test' against a remote Windows VM
export GO_REMOTE_WINDOWS="User@192.168.2.55"

# Config history late so oh-my-zsh doesn't get in the way
export HISTFILE=~/.zsh_history
export HISTSIZE=1000000
export SAVEHIST=$HISTSIZE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_DUPS
setopt HIST_FCNTL_LOCK
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY_TIME

setopt no_autocd
setopt no_autopushd

if [ -e /usr/local/bin/code ]; then
  EXTFILE=${DOTFILES_HOME}/vscode/install_extensions.sh
  # Only regenerate the Cursor extension export script once per day
  # find returns the file if it's <24h old; empty means stale/missing
  if [[ ! -f $EXTFILE || -z $(command find "$EXTFILE" -mtime -1 2>/dev/null) ]]; then
    echo '#!/bin/sh' > ${EXTFILE}
    chmod 755 ${EXTFILE}
    code --list-extensions | xargs -L 1 echo code --install-extension >> ${EXTFILE}
  fi
fi

############## BEGIN LOKI-SHELL #####################

# NOTE when changing the Loki URL, also remember to change the promtail config: ~/.loki-shell/config/promtail-logging-config.yaml
# this should be 127.0.0.1, not localhost, because sometimes localhost resolves to an IPv6 address, and the lookup fails
export LOKI_URL="http://127.0.0.1:4110"

[ -f ~/.loki-shell/shell/loki-shell.zsh ] && source ~/.loki-shell/shell/loki-shell.zsh

############## END LOKI-SHELL   #####################
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# bun completions
[ -s "/Users/hairyhenderson/.bun/_bun" ] && source "/Users/hairyhenderson/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

if $PROFILE_STARTUP; then
  unsetopt xtrace
  exec 2>&3 3>&-
fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/hairyhenderson/.lmstudio/bin"
# End of LM Studio CLI section

