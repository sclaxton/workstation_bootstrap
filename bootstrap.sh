#!/bin/sh
echo "determie OS..."
if `echo ${OSTYPE} | grep "linux" 1>/dev/null 2>&1`
then
	if `uname -m | grep "64" 1>/dev/null 2>&1`
	then
		cd ${HOME} && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
	elif `uname -m | grep "32" 1>/dev/null 2>&1`
    then
		cd ${HOME} && wget -O - "https://www.dropbox.com/download?plat=lnx.x86" | tar xzf -
	fi
	chmod +x ${PWD}/configure.py
	sudo add-apt-repository ppa:gnome-terminator
	sudo apt-get update
	sudo apt-get install terminator
	mkdir -p ${HOME}/.config/terminator/
	\cp ${PWD}/terminator-solarized/config ${HOME}/.config/terminator/
	echo "source db command..."
	\cp ${PWD}/control.py ${HOME}/bin/
elif `echo ${OSTYPE} | grep "darwin" 1>/dev/null 2>&1`
then
	open https://www.dropbox.com/downloading?os=mac
	ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
	brew install git
fi
echo "move bashrc and aliases to appropriate places..."
\cp ${PWD}/.bashrc ${HOME}
\cp ${PWD}/.bash_aliases ${HOME}
\cp ${PWD}/.bash_profile ${HOME}
echo "reinstalling spf13 config for vim..."
chmod +x ${PWD}/spf13-vim/bootstrap.sh
sudo ${PWD}/spf13-vim/bootstrap.sh
echo "make vim pretty..."
\cp ${PWD}/vim-colors-solarized/colors/solarized.vim ${HOME}/.vim
echo "launch vm command..."
chmod +x ${PWD}/vm
PATH=$PATH:${HOME}/Dropbox/spencerclaxton/
export PATH
