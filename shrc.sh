#!/bin/bash
# shellcheck disable=SC2155

# Colourful manpages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Set to avoid `env` output from changing console colour
export LESS_TERMEND=$'\E[0m'

# Print field by number
field() {
  ruby -ane "puts \$F[$1]"
}

# Setup paths

# Remove from anywhere in PATH
remove_from_path() {
  [ -d "$1" ] || return
  PATHSUB=":$PATH:"
  PATHSUB=${PATHSUB//:$1:/:}
  PATHSUB=${PATHSUB#:}
  PATHSUB=${PATHSUB%:}
  export PATH="$PATHSUB"
}

# Add to the start of PATH if it exists
add_to_path_start() {
  [[ -d "$1" ]] || return
  remove_from_path "$1"
  export PATH="$1:${PATH}"
}

# Add to the end of PATH if it exists
add_to_path_end() {
  [[ -d "$1" ]] || return
  remove_from_path "$1"
  export PATH="${PATH}:$1"
}

# Add to PATH even if it doesn't exist
force_add_to_path_start() {
  remove_from_path "$1"
  export PATH="$1:${PATH}"
}

quiet_which() {
  command -v "$1" >/dev/null
}

if [[ -n "${MACOS}" ]]; then
  add_to_path_start "/opt/homebrew/bin"
elif [[ -n "${LINUX}" ]]; then
  add_to_path_start "/home/linuxbrew/.linuxbrew/bin"
fi

add_to_path_start "/usr/local/bin"
add_to_path_end "${HOME}/.dotfiles/bin"

# Setup Go development
export GOPATH="${HOME}/.gopath"
add_to_path_end "${GOPATH}/bin"

# Registering the psql client cli tool
add_to_path_end "/opt/homebrew/opt/libpq/bin"

# Aliases
alias mkdir="mkdir -vp"
alias df="df -H"
alias rm="rm -iv"
alias mv="mv -iv"
alias cp="cp -irv"
alias du="du -sh"
alias make="nice make"
alias less="less --ignore-case --raw-control-chars"
alias rsync="rsync --partial --progress --human-readable --compress"
alias rg="rg --colors 'match:style:nobold' --colors 'path:style:nobold'"
alias be="bundle exec"
alias sha256="shasum -a 256"
alias perlsed="perl -p -e"

# Command-specific stuff
if quiet_which brew; then
  eval "$(brew shellenv)"

  export HOMEBREW_DEVELOPER=1
  export HOMEBREW_BOOTSNAP=1
  export HOMEBREW_BUNDLE_INSTALL_CLEANUP=1
  export HOMEBREW_BUNDLE_DUMP_DESCRIBE=1
  export HOMEBREW_NO_ENV_HINTS=1
  export HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=1
  export HOMEBREW_CLEANUP_MAX_AGE_DAYS=30
  export HOMEBREW_NO_VERIFY_ATTESTATIONS=1
  export HOMEBREW_NO_VERIFY_ATTESTATIONS=1

  add_to_path_end "${HOMEBREW_PREFIX}/Library/Homebrew/shims/gems"

  # Specifically want this to expand when defined, not when run.
  # shellcheck disable=SC2139
  alias homebrew="${HOMEBREW_PREFIX}/bin/brew"
  alias portableruby="${HOMEBREW_PREFIX}/Library/Homebrew/vendor/portable-ruby/current/bin/ruby"
  alias portablebundle="${HOMEBREW_PREFIX}/Library/Homebrew/vendor/portable-ruby/current/bin/bundle"

  alias hbc='cd $HOMEBREW_REPOSITORY/Library/Taps/homebrew/homebrew-core'
fi



# enable direnv (if installed)
if quiet_which direnv; then
   export DIRENV_WARN_TIMEOUT=1m
   export DIRENV_LOG_FORMAT="$(printf "\033[2mdirenv: %%s\033[0m")"
   eval "$(direnv hook zsh)"
   _direnv_hook() {
     eval "$(direnv export zsh 2> >(egrep -v -e '^....direnv: export' >&2))"
   }
fi

# enable mcfly (if installed)
if quiet_which mcfly; then
   eval "$(mcfly init zsh)"
fi

# enable mise (if installed)
# which mise &>/dev/null && eval "$(mise activate zsh)"
if quiet_which direnv; then
   eval "$(mise activate zsh)"
   eval "$(mise hook-env -s zsh)"
fi

if quiet_which delta; then
  export GIT_PAGER='delta'
else
  # shellcheck disable=SC2016
  export GIT_PAGER='less -+$LESS -RX'
fi

if quiet_which eza; then
  alias ls="eza --classify --group --git"
elif [[ -n "${MACOS}" ]]; then
  alias ls="ls -F"
else
  alias ls="ls -F --color=auto"
fi

if quiet_which bat; then
  export BAT_THEME="ansi"
  alias cat="bat"
  export HOMEBREW_BAT=1
fi

if quiet_which prettyping; then
  alias ping="prettyping --nolegend"
fi

if quiet_which dust; then
  alias du="dust"
fi

if quiet_which duf; then
  alias df="duf"
fi

if quiet_which htop; then
  alias top="sudo htop"
fi

# Configure environment
export CLICOLOR=1

# OS-specific configuration
if [[ -n "${MACOS}" ]]; then
  export GREP_OPTIONS="--color=auto"
  export VAGRANT_DEFAULT_PROVIDER="vmware_fusion"
  export HOMEBREW_ENFORCE_SBOM=0

  alias locate="mdfind -name"
  alias finder-hide="setfile -a V"

  # output what's listening on the supplied port
  on-port() {
    sudo lsof -nP -i4TCP:"$1"
  }

  # make no-argument find Just Work.
  find() {
    local arg
    local path_arg
    local dot_arg

    for arg; do
      [[ ${arg} =~ "^-" ]] && break
      path_arg="${arg}"
    done

    [[ -z "${path_arg}" ]] && dot_arg="."

    command find "${dot_arg}" "$@"
  }

  # Only run this if it's not already running
  if quiet_which touchid-enable-pam-sudo; then
      pgrep -fq touchid-enable-pam-sudo || touchid-enable-pam-sudo --quiet
  fi
elif [[ -n "${LINUX}" ]]; then
  quiet_which keychain && eval "$(keychain -q --eval --agents ssh id_rsa)"

  # Run dircolors if it exists
  quiet_which dircolors && eval "$(dircolors -b)"

  add_to_path_end "/data/github/shell/bin"
  add_to_path_start "/workspaces/github/bin"

  alias su="/bin/su -"
  alias open="xdg-open"
elif [[ -n "${WINDOWS}" ]]; then
  open() {
    # shellcheck disable=SC2145
    cmd /C"$@"
  }
fi

# Run rbenv/nodenv if they exist
if quiet_which rbenv; then
  shims="$(rbenv root)/shims"
  if ! [[ -d "${shims}" ]]; then
    rbenv rehash
  fi
  add_to_path_start "${shims}"
fi

if quiet_which nodenv; then
  shims="$(nodenv root)/shims"
  if ! [[ -d "${shims}" ]]; then
    nodenv rehash
  fi
  add_to_path_start "${shims}"
fi

# Load GITHUB_TOKEN from gh
if quiet_which gh; then
  export GITHUB_TOKEN="$(gh auth token)"
  export GH_TOKEN="${GITHUB_TOKEN}"
  export HOMEBREW_GITHUB_API_TOKEN="${GITHUB_TOKEN}"
  export JEKYLL_GITHUB_TOKEN="${GITHUB_TOKEN}"
fi

# Set up editor
if quiet_which cursor; then
  export EDITOR="cursor"
  alias code="cursor"
elif quiet_which code; then
  export EDITOR="code"
else
	export EDITOR="vim"
fi

if quiet_which code; then
  export GIT_EDITOR="${EDITOR} -w"
  export SVN_EDITOR="${GIT_EDITOR}"

  # Edit Rails credentials in VSCode
  rails-credentials-edit-production() {
    EDITOR="${EDITOR} -w" bundle exec rails credentials:edit --environment production
  }
  rails-credentials-edit-development() {
    EDITOR="${EDITOR} -w" bundle exec rails credentials:edit --environment development
  }
else
  export EDITOR="vim"
fi

# Load secrets
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets"


# Save directory changes
cd() {
  builtin cd "$@" || return
  [[ -n "${TERMINALAPP}" ]] && command -v set_terminal_app_pwd >/dev/null &&
    set_terminal_app_pwd
  pwd >"${HOME}/.lastpwd"
  ls
}

# Use ruby-prof to generate a call stack
ruby-call-stack() {
  ruby-prof --printer=call_stack --file=call_stack.html -- "$@"
}

# Pretty-print JSON files
json() {
  [[ -n "$1" ]] || return
  cat "$1" | jq .
}

# Pretty-print Homebrew install receipts
receipt() {
  [[ -n "$1" ]] || return
  json "${HOMEBREW_PREFIX}/opt/$1/INSTALL_RECEIPT.json"
}

# Move files to the Trash folder
trash() {
  mv "$@" "${HOME}/.Trash/"
}

# GitHub API shortcut
github-api-curl() {
  curl -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/$1" | jq .
}

# Clear entire screen buffer
clearer() {
  tput reset
}
