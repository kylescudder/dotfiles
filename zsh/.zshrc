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

# Customize Nerdfetch to show Catppuccin theme styled ASCII art and colors

setopt promptsubst

# bun completions
[ -s "/home/kyle/.bun/_bun" ] && source "/home/kyle/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Initialize Bun
[ -s "$BUN_INSTALL/bun.sh" ] && source "$BUN_INSTALL/bun.sh"

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/npm/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# T3 nightly service wrapper
npx() {
  local package="${1:-}"

  if [[ "$package" != t3@*-nightly.* ]]; then
    command npx "$@"
    return $?
  fi

  local version="${package#t3@}"
  local root="$HOME/.cache/t3-nightlies"
  local install_dir="$root/$version"
  local t3_bin="$install_dir/node_modules/.bin/t3"
  local node_pty_dir="$install_dir/node_modules/node-pty"
  local pty_bin="$node_pty_dir/build/Release/pty.node"

  echo "Preparing T3 $version for t3code.service..."

  mkdir -p "$install_dir" || return 1

  if [[ ! -x "$t3_bin" ]]; then
    echo "Installing $package..."

    command npm install \
      --prefix "$install_dir" \
      --no-save \
      --no-package-lock \
      "$package" || return 1
  fi

  if [[ ! -f "$pty_bin" ]]; then
    echo "Compiling node-pty for Linux..."

    (
      cd "$node_pty_dir" || exit 1
      command npm exec --yes --package=node-gyp -- node-gyp rebuild
    ) || {
      echo "node-pty compilation failed." >&2
      return 1
    }
  fi

  if [[ ! -f "$pty_bin" ]]; then
    echo "Build completed without creating $pty_bin" >&2
    return 1
  fi

  ln -sfn "$install_dir" "$root/current.new" || return 1
  mv -Tf "$root/current.new" "$root/current" || return 1

  systemctl --user daemon-reload
  systemctl --user restart t3code.service || {
    echo "The new version was installed, but the service failed to start." >&2
    systemctl --user status t3code.service --no-pager
    return 1
  }

  echo
  echo "T3 $version is now running as t3code.service."
  systemctl --user status t3code.service --no-pager --lines=5
}

# pnpm
export PNPM_HOME="/home/kyle/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
