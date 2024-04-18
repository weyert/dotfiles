# always source zprofile regardless of whether this is/isn't a login shell
source ~/.zprofile

# load shared shell configuration
source ~/.shrc

# History file
export HISTFILE=~/.zsh_history

# Don't show duplicate history entires
setopt hist_find_no_dups

# Remove unnecessary blanks from history
setopt hist_reduce_blanks

# Share history between instances
setopt share_history

# Don't hang up background jobs
setopt no_hup

# autocorrect command and parameter spelling
setopt correct
setopt correctall

# use emacs bindings even with vim as EDITOR
bindkey -e

# fix backspace on Debian
[ -n "$LINUX" ] && bindkey "^?" backward-delete-char

# fix delete key on macOS
[ -n "$MACOS" ] && bindkey '\e[3~' delete-char

# alternate mappings for Ctrl-U/V to search the history
bindkey "^u" history-beginning-search-backward
bindkey "^v" history-beginning-search-forward

# enable autosuggestions
ZSH_AUTOSUGGESTIONS="$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[ -f "$ZSH_AUTOSUGGESTIONS" ] && source "$ZSH_AUTOSUGGESTIONS"

# enable direnv (if installed)
export DIRENV_LOG_FORMAT="$(printf "\033[2mdirenv: %%s\033[0m")"
which direnv &>/dev/null && eval "$(direnv hook zsh)"
_direnv_hook() {
	eval "$(direnv export zsh 2> >(egrep -v -e '^....direnv: export' >&2))"
}

# enable mcfly (if installed)
which mcfly &>/dev/null && eval "$(mcfly init zsh)"

asdf_dir="$(brew --prefix asdf)/libexec"
if [[ -d $asdf_dir ]]; then
	source $asdf_dir/asdf.sh
	if [[ -f $asdf_dir/completions/asdf.bash ]]; then
		source $asdf_dir/completions/asdf.bash
	fi

	# Set the path of `node-build` to ASDF's node-build
	export NODE_BUILD_DEFINITIONS="$HOME/.asdf/plugins/nodejs/.node-build/share/node-build"
fi

# More colours with grc
# shellcheck disable=SC1090
GRC_ZSH="$HOMEBREW_PREFIX/etc/grc.zsh"
[ -f "$GRC_ZSH" ] && source "$GRC_ZSH"

# zsh-specific aliases
alias zmv="noglob zmv -vW"
alias rake="noglob rake"
alias be="nocorrect noglob bundle exec"

# enable zplug
if brew ls --versions zplug >/dev/null; then
	export ZPLUG_HOME=/opt/homebrew/opt/zplug
	source $ZPLUG_HOME/init.zsh

	#
	# Plugins
	zplug "zsh-users/zsh-autosuggestions"
	zplug "zsh-users/zsh-completions"
	zplug "zsh-users/zsh-syntax-highlighting", defer:2
	zplug "zsh-users/zsh-history-substring-search", defer:3

	# Install plugins if there are plugins that have not been installed
	if ! zplug check --verbose; then
		printf "Install? [y/N]: "
		if read -q; then
			echo
			zplug install
		fi
	fi

	# Then, source plugins and add commands to $PATH
	zplug load
fi

# Add LLVM to path
export PATH="$PATH:$(brew --prefix llvm@16)/bin"
export LDFLAGS="$LDFLAGS -L$(brew --prefix llvm@16)/lib"
export CPPFLAGS="$CPPFLAGS -I$(brew --prefix llvm@16)/include"

# pnpm
export PNPM_HOME="/Users/weyertdeboer/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# bun developer build
export BUN_DEBUG_INSTAL="$HOME/Development/Projects/Opensource/bun/packages/debug-bun-darwin-aarch64"
export PATH="$BUN_DEBUG_INSTAL:$PATH"

# to avoid non-zero exit code
true

# bun completions
[ -s "/Users/weyertdeboer/.bun/_bun" ] && source "/Users/weyertdeboer/.bun/_bun"
export PATH="/opt/homebrew/opt/dotnet@6/bin:$PATH"
