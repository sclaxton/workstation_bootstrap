#!/bin/sh
linux_config(){
    if [ ! `dpkg --get-selections | grep *vim* 1>/dev/null 2>&1`]
    then
        sudo apt-get install vim
    fi
    sudo apt-get update vim && sudo apt-get dist-upgrade vim
	chmod +x ${PWD}/configure.py
	sudo apt-get update
	sudo add-apt-repository ppa:gnome-terminator
    if [ ! `dpkg --get-selections | grep *terminator* 1>/dev/null 2>&1`]
    then
        sudo apt-get install terminator
    fi
	mkdir -p ${HOME}/.config/terminator/
	\cp ${PWD}/terminator-solarized/config ${HOME}/.config/terminator/
    if [ ! `dpkg --get-selections | grep *git* 1>/dev/null 2>&1`]
    then
        sudo apt-get install git
    fi
    if [ ! `dpkg --get-selections | grep *python-setuptools* 1>/dev/null 2>&1`]
    then
        sudo apt-get install python-setuptools
    fi
	echo "source db command..."
	\cp ${PWD}/control.py ${HOME}/bin/bash
}
mac_cli_tools(){
    echo "downloading apple developer cli tools"
    OSX_VERS=$(sw_vers -productVersion | awk -F "." '{print $2}')
    # Get Xcode CLI tools
    # https://devimages.apple.com.edgekey.net/downloads/xcode/simulators/index-3905972D-B609-49CE-8D06-51ADC78E07BC.dvtdownloadableindex
    TOOLS=clitools.dmg
    if [ "$OSX_VERS" -eq 7 ]; then
            DMGURL=http://devimages.apple.com/downloads/xcode/command_line_tools_for_xcode_os_x_lion_april_2013.dmg
    elif [ "$OSX_VERS" -eq 8 ]; then
                DMGURL=http://devimages.apple.com/downloads/xcode/command_line_tools_for_xcode_os_x_mountain_lion_april_2013.dmg
    fi
    curl "$DMGURL" -o "$TOOLS"
    TMPMOUNT=`/usr/bin/mktemp -d /tmp/clitools.XXXX`
    hdiutil attach "$TOOLS" -mountpoint "$TMPMOUNT"
    sudo installer -pkg "$(find $TMPMOUNT -name '*.mpkg')" -target /
    hdiutil detach "$TMPMOUNT"
    rm -rf "$TMPMOUNT"
    rm "$TOOLS"
}
mac_config() {
    mac_cli_tools
    open https://www.dropbox.com/downloading?os=mac
    ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
    brew doctor
    brew update
    if [ ! `brew list | grep *git* 1>/dev/null 2>&1`]
    then
        brew install git
    fi
    if [ ! `brew list | grep *vim* 1>/dev/null 2>&1`]
    then
        brew install vim
    fi
    brew upgrade vim
    brew upgrade git
}
general_config() {
    echo "Install pip..."
    sudo easy_install pip
    echo "Identify git..."
    git config --global user.email "saclaxton@gmail.com"
    git config --global user.name "Spencer Claxton"
    echo "move bashrc and aliases to appropriate places..."
    \cp ${PWD}/.bashrc ${HOME}
    \cp ${PWD}/.bash_aliases ${HOME}
    \cp ${PWD}/.bash_profile ${HOME}
    echo "installing/updating spf13 platform for vim..."
    chmod +x ${PWD}/spf13-vim/bootstrap.sh
    sudo ${PWD}/spf13-vim/bootstrap.sh
    echo "Launch vm command..."
    chmod +x ${PWD}/vm
    if [ ! -a ${HOME}/bin/ ]
    then sudo mkdir ${HOME}/bin/
    fi
    \cp ${PWD}/vm ${HOME}/bin/
    echo "reinstalling spf13 config for vim..."
    chmod +x ${PWD}/spf13-vim/bootstrap.sh
    sudo ${PWD}/spf13-vim/bootstrap.sh
}

# Main Script
echo "determie OS..."
if `echo ${OSTYPE} | grep "linux" 1>/dev/null 2>&1`
then
    linux_config
    if `uname -m | grep "64" 1>/dev/null 2>&1`
    then
        cd ${HOME} && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
    elif `uname -m | grep "32" 1>/dev/null 2>&1`
    then
        cd ${HOME} && wget -O - "https://www.dropbox.com/download?plat=lnx.x86" | tar xzf -
    fi
elif `echo ${OSTYPE} | grep "darwin" 1>/dev/null 2>&1`
then
    mac_config
fi
general_config
