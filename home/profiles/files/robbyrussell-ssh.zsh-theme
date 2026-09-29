# Custom robbyrussell variant — shows user@host with "(SSH)" when connected remotely
# Based on the standard robbyrussell theme bundled with oh-my-zsh

ssh_prompt_info() {
  [[ -n $SSH_CONNECTION ]] && echo " %{$fg[grey]%}(SSH)%{$reset_color%}"
}

# Arrow (green on success, red on failure) + user@host(SSH?) + directory
PROMPT="%(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} )"
PROMPT+="%{$fg_bold[green]%}%n%{$fg[cyan]%}@%{$fg_bold[green]%}%m"
PROMPT+='$(ssh_prompt_info)'
PROMPT+=" %{$fg[cyan]%}%~%{$reset_color%}"
PROMPT+=' $(git_prompt_info)'

# Git prompt styling (matches original robbyrussell)
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"