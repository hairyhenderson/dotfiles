#!/usr/local/bin/zsh
# dave.zsh-theme
# Use with a dark background and 256-color terminal!

function prompt_char {
  git branch >/dev/null 2>/dev/null && echo "±" && return
  echo '○'
}

function box_name {
    hostname -s
}

function prompt {
	current_dir="${PWD/#$HOME/~}"
	git_info="$(git_prompt_info)"
	ret_status="%(?::%{$fg_bold[red]%})"
	prompt_char="${ret_status}$(prompt_char)"

	echo -n "%{$FG[239]%}╭─(%{$FG[040]%}%n%{$reset_color%}%{$FG[239]%})@%{$reset_color%}%{$FG[033]%}$(box_name)%{$reset_color%}%{$FG[239]%}:%{$reset_color%}%{$terminfo[bold]$FG[226]%}${current_dir}%{$reset_color%}${git_info}
%{$FG[239]%}╰─${prompt_char}%{$reset_color%} "
}

PROMPT='$(prompt)'

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$FG[239]%}⎇%{$reset_color%} %{$fg[255]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$FG[202]%}✘"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$FG[040]%}✔"
