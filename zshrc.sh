# check if this is a login shell
[ "$0" = "-zsh" ] && export LOGIN_ZSH=1

# run zprofile if this is not a login shell
[ -n "$LOGIN_ZSH" ] && source ~/.zprofile

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

# use emacs bindings even with vim as EDITOR
bindkey -e

# fix backspace on Debian
[ -n "$LINUX" ] && bindkey "^?" backward-delete-char

# fix delete key on macOS
[ -n "$MACOS" ] && bindkey '\e[3~' delete-char

# alternate mappings for Ctrl-U/V to search the history
bindkey "^u" history-beginning-search-backward
bindkey "^v" history-beginning-search-forward

# Enable Java Runtime
JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home
export JAVA_HOME
export PATH=$PATH:$JAVA_HOME/bin

# Enable ZSH zplug feature
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

# Plugins
zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh, from:github, as:theme
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-history-substring-search", defer:3

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi
# Load zplugzplug load

# Enable the spaceship functionality
autoload -U promptinit; promptinit
prompt spaceship
[[ /usr/local/bin/kubectl ]] && source <(kubectl completion zsh)
export PATH="/usr/local/opt/openjdk/bin:$PATH"

# Enable ava switching
jdk() {
        version=$1
        export JDK_HOME=$(/usr/libexec/java_home -v"$version");
        export JAVA_PATH=$JDK_HOME
  	export JAVA_HOME=$JDK_HOME
        java -version
 }
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/opt/openjdk/bin:$PATH"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
