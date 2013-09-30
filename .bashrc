# Check for an interactive session
[ -z "$PS1" ] && return
source ${HOME}/.bash_aliases
source /etc/profile
export PATH=$PATH:${HOME}/bin/
