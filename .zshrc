
# Z shell

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
#export SDKMAN_DIR="/Users/yoomlam/.sdkman"
#[[ -s "/Users/yoomlam/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/yoomlam/.sdkman/bin/sdkman-init.sh"

#autoload -U colors && colors
#PS1="%{$fg[red]%}%n%{$reset_color%}@%{$fg[blue]%}%m %{$fg[yellow]%}%~ %{$reset_color%}%% "

autoload -U promptinit && promptinit
prompt clint

# right-side
RPROMPT="%F{111}%K{000}[%D{%f/%m/%y}|%@]"

# source ~/.alias

