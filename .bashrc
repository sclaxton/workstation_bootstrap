# Check for an interactive session
[ -z "$PS1" ] && return
source ${HOME}/.bash_aliases
source /etc/profile
export PATH=$PATH:${HOME}/bin/:
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
export VIRTUALENVWRAPPER_SCRIPT=/usr/local/bin/virtualenvwrapper.sh
git config --global user.email "saclaxton@gmail.com"
git config --global user.name "Spencer Claxton"
git config --global credential.helper cache

