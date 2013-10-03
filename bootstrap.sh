#!/bin/sh
ORIGIN=https://github.com/sclaxton/workstation_bootstrap.git
VIMVER=7.3.692
PYTHONVER=2.7.2
linux_config(){
    if [ ! `dpkg --get-selections | grep *vim* 1>/dev/null 2>&1`]
    then
        sudo apt-get install "vim=${VIMVER}"
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
	sudo \cp ${PWD}/control.py ${HOME}/bin/bash
}
# Installs CLI tools distributed with Mac dev tools
mac_cli_tools(){
    echo "downloading apple developer cli tools"
    osx_vers=$(sw_vers -productVersion | awk -F "." '{print $2}')
    # Get Xcode CLI tools
    # https://devimages.apple.com.edgekey.net/downloads/xcode/simulators/index-3905972D-B609-49CE-8D06-51ADC78E07BC.dvtdownloadableindex
    tools=clitools.dmg
    if [ "$osx_vers" -eq 7 ]; then
            dmg_url=http://devimages.apple.com/downloads/xcode/command_line_tools_for_xcode_os_x_lion_april_2013.dmg
    elif [ "$osx_vers" -eq 8 ]; then
                dmg_url=http://devimages.apple.com/downloads/xcode/command_line_tools_for_xcode_os_x_mountain_lion_april_2013.dmg
    fi
    curl "$dmg_url" -o "$tools"
    tmpmount=`/usr/bin/mktemp -d /tmp/clitools.XXXX`
    hdiutil attach "$tools" -mountpoint "$tmpmount"
    sudo installer -pkg "$(find $tmpmount -name '*.mpkg')" -target /
    hdiutil detach "$tmpmount"
    rm -rf "$tmpmount"
    rm "$tools"
}
# Parses a string of numbers seperated by periods
# e.g. '2.0.7' and returns a regexp e.g. '2\.0\.7'
parse_version() {
    str=$1
    res=''
    for (( i = 0; i < ${#1}; ++i)); do
        curr=${str:i:1}
        if [ $curr == '.' ]
        then res=$res'\.'
        else res=$res$curr
        fi
    done
    echo $res
}
# Script that brew installs specific version of the $pkg param
# brew_version $pkg $version, e.g. version=2.0
brew_version() {
    regex=`parse_version $2`
    len=${#2}
    formula=`brew versions $1 | grep ${regex}' '`
    formula=`echo ${formula:len} | sed -e 's/^[ \t]*//'`
    (cd `brew --prefix`; brew uninstall $1; ${formula}; brew install $1; brew unlink $1 && brew link --overwrite $1)
}
# General configure for Mac OSX
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
        brew_version vim $VIMVER
    fi
    brew upgrade github
}
# Configure python, loading the regular libraries
python_config(){
    echo "Install pip..."
    sudo easy_install pip
    sudo easy_install -U mock
    sudo pip install -U mock

}
# Add git config to .bashrc so git configures on login
# Sync downloaded folder with remote github repo for versioning
git_config(){
    echo "Identify git..."
    email='git config --global user.email "saclaxton@gmail.com"'
    user='git config --global user.name "Spencer Claxton"'
    pass='git config --global credential.helper cache'
    echo "Sync repo with origin..."
    command="git init ${PWD} && git remote add origin ${ORIGIN} && git pull origin master"
    newl=$'\n'
    echo "${email}${newl}${user}${newl}${pass}${newl}${command}"  >> ${PWD}/.bashrc
}
# Populate .bash files on bootsrapped system
bash_config(){
    echo "move bashrc and aliases to appropriate places..."
    \cp ${PWD}/.bashrc ${HOME}
    \cp ${PWD}/.bash_aliases ${HOME}
    \cp ${PWD}/.bash_profile ${HOME}
}
# Bootstrap vim with spf13-vim platform
vim_config(){
    echo "installing/updating spf13 platform for vim..."
    chmod +x ${PWD}/spf13-vim/bootstrap.sh
    sudo ${PWD}/spf13-vim/bootstrap.sh
}
# configure general settings after running all the specific configs
general_config() {
    git_config
    bash_config
    vim_config
    python_config
    echo "Launch vm command..."
    chmod +x ${PWD}/vm
    if [ ! -a ${HOME}/bin/ ]
    then sudo mkdir ${HOME}/bin/
    fi
    \cp ${PWD}/vm ${HOME}/bin/
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
