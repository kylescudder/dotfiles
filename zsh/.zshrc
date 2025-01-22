# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/kyle/.zshrc'
fpath=(~/.zsh/completions $fpath)

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Zsh config
# export ZSH="$HOME/.oh-my-zsh"
# ZSH_THEME="robbyrussell" # Change theme if needed

# Starship prompt setup with Catppuccin theme
eval "$(starship init zsh)"

# Nerdfetch setup (assuming installed globally or in a specific path)
alias fastfetch="fastfetch"
alias spt="~/Documents/Repos/scripts/launchspt"

# Customize Nerdfetch to show Catppuccin theme styled ASCII art and colors
fastfetch

setopt promptsubst

# bun completions
[ -s "/home/kyle/.bun/_bun" ] && source "/home/kyle/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Initialize Bun
[ -s "$BUN_INSTALL/bun.sh" ] && source "$BUN_INSTALL/bun.sh"

source ~/.config/shmux/shmux.sh

export PATH=$PATH:/home/kyle/.spicetify
