#!/bin/sh
VIMVER=7.3
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
brew_version() {
    regex=`parse_version $2`
    formula=`brew versions $1 | grep ${regex}' '`
    len=${#2}
    formula=`echo ${formula:len} | sed -e 's/^[ \t]*//'`
    echo $formula
    (cd `brew --prefix`; brew uninstall $1; ${formula}; brew install $1; brew unlink $1 && brew link --overwrite $1)
}

