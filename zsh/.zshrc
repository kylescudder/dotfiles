# Lines configured by zsh-newuser-install
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

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
alias spt="launchspt"

# Customize Nerdfetch to show Catppuccin theme styled ASCII art and colors
fastfetch

setopt promptsubst

[[ -f ~/Documents/Repos/schmerdr/schmerdr.sh ]] && source ~/Documents/Repos/schmerdr/schmerdr.sh
export EDITOR=nvim
