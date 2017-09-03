if [ -d "$HOME/gocode" ]; then
  export GOPATH="$HOME/gocode"
fi
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="$HOME/bin:$GOPATH/bin:$PATH:$HOME/.rvm/bin:/usr/local/opt/go/libexec/bin"
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="/usr/local/opt/gettext/bin:$PATH"
export PATH="/usr/local/go/bin:$PATH"
export PATH="$HOME/bin/docker:$HOME/bin/packer:$HOME/bin/terraform:$PATH"

export EDITOR="vim"

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

alias dockviz="docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock nate/dockviz"

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

source $DOTFILES_HOME/antigen/antigen.zsh

COMPLETION_WAITING_DOTS="true"

# 170ms
antigen use oh-my-zsh

# 90ms
antigen bundle git
# antigen bundle heroku
# antigen bundle pip
# 90ms
antigen bundle docker
# 80ms
antigen bundle node
# 80ms
# antigen bundle brew
# 80ms
#antigen bundle rvm
# antigen bundle vagrant
# antigen bundle python
# 80ms
# antigen bundle command-not-found
# 130ms
#antigen bundle mvn

# 140ms
#antigen bundle zsh-users/zsh-syntax-highlighting

# 100ms
antigen theme $DOTFILES_HOME/themes dave

# 1520ms
antigen apply

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
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
