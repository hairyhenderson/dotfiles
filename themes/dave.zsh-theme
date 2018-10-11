#!/usr/local/bin/zsh
# dave.zsh-theme
# Use with a dark background and 256-color terminal!

ret_status="%(?::%{$fg_bold[red]%})"

function prompt_char {
  git branch >/dev/null 2>/dev/null && echo "±" && return
  echo '○'
}

function box_name {
    hostname -s
}

function docker_host {
	if [ ! -z "${DOCKER_MACHINE_NAME}" ]; then
		#local GEAR="⚙"
		local GEAR="\u2699"
		echo -ne "$FG[239]${GEAR}$reset_color $FG[033]${DOCKER_MACHINE_NAME}$reset_color"
	fi
}

current_dir='${PWD/#$HOME/~}'
git_info='$(git_prompt_info)'
prompt_char='${ret_status}$(prompt_char)'
docker_info='$(docker_host)'

PROMPT="%{$FG[239]%}╭─(%{$FG[040]%}%n%{$reset_color%}%{$FG[239]%})@%{$reset_color%}%{$FG[033]%}$(box_name)%{$reset_color%}%{$FG[239]%}:%{$reset_color%}%{$terminfo[bold]$FG[226]%}${current_dir}%{$reset_color%}${git_info} ${docker_info}
%{$FG[239]%}╰─${prompt_char}%{$reset_color%} "

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$FG[239]%}⎇%{$reset_color%} %{$fg[255]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$FG[202]%}✘"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$FG[040]%}✔"
