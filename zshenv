export IRCNICK="dangersalad"
export IRCNAME="dangersalad"
export IRCUSER="dangersalad"
export IRCSERVER="irc.freenode.net"

export PWSAFE_DATABASE=$HOME/.pwsafe/db.psafe3
export RANDFILE=$HOME/.pwsafe/rnd

export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on'
export JAVA_FONTS=/usr/share/fonts/TTF

# python virtualenvwrapper stuff
export WORKON_HOME=${HOME}/dev/snakepit
if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
    source /usr/local/bin/virtualenvwrapper.sh
elif [ -f /usr/bin/virtualenvwrapper.sh ]; then
    source /usr/bin/virtualenvwrapper.sh
fi

export GOPATH=${HOME}/dev/go

if [ "${PATH%%:*}" != "$GOPATH/bin" ]
then
    if [ -d "$GOPATH/bin" ]
    then
        export PATH="$GOPATH/bin:$PATH"
    fi
fi

