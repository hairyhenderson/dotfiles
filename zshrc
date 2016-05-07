export GOPATH="$HOME/gocode"
export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/bin:$GOPATH/bin:$PATH:$HOME/.rvm/bin:/usr/local/opt/go/libexec/bin"
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="$HOME/bin/packer:$PATH"
export PATH="$HOME/bin/terraform:$PATH"
export PATH="$GOPATH/src/github.com/docker/machine/bin:$PATH"
# Set this to true to profile the start
PROFILE_STARTUP=false
if $PROFILE_STARTUP; then
  zmodload zsh/datetime
  setopt promptsubst
  PS4='+$EPOCHREALTIME %N:%i> '
  exec 3>&2 2>/tmp/startlog.$$
  setopt xtrace prompt_subst
fi

export DOTFILES_HOME=$(dirname `realpath ~/.zshrc`)

# installed by the `awscli` homebrew package
if [ -f /usr/local/share/zsh/site-functions/_aws ]; then
  source /usr/local/share/zsh/site-functions/_aws
fi

if [ -d ~/.nvm ]; then
  export NVM_DIR=~/.nvm
  source $(brew --prefix nvm)/nvm.sh
  nvm use node >/dev/null
fi

# call nvm use automatically whenever you enter a directory that contains an .nvmrc file 
autoload -U add-zsh-hook
load-nvmrc() {
  if [[ -f .nvmrc && -r .nvmrc ]]; then
    nvm use
  elif [[ $(nvm version) != $(nvm version default)  ]]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

#unalias run-help &> /dev/null
#autoload run-help
#HELPDIR=/usr/local/share/zsh/help

source $DOTFILES_HOME/antigen/antigen.zsh
# source $DOTFILES_HOME/zgen.zsh

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
antigen bundle command-not-found
# 130ms
#antigen bundle mvn

# 140ms
antigen bundle zsh-users/zsh-syntax-highlighting

# 100ms
antigen theme $DOTFILES_HOME/themes dave

# 1520ms
antigen apply


if $PROFILE_STARTUP; then
  unsetopt xtrace
  # restore stderr to the value saved in FD 3
  exec 2>&3 3>&-
fi

[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
