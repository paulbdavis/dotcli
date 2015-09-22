export PWSAFE_DATABASE=$HOME/.pwsafe/db.psafe3
export RANDFILE=$HOME/.pwsafe/rnd

export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on'
export JAVA_FONTS=/usr/share/fonts/TTF

# python virtualenvwrapper stuff
export WORKON_HOME=${HOME}/dev/snakepit
if [[ -f /usr/local/bin/virtualenvwrapper.sh ]]; then
    source /usr/local/bin/virtualenvwrapper.sh
elif [[ -f /usr/bin/virtualenvwrapper.sh ]]; then
    source /usr/bin/virtualenvwrapper.sh
fi

# golang
export GOPATH=${HOME}/dev/go
export GOBIN=$GOPATH/bin
export GOARCH=amd64
export GOOS=linux

# android
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SWT=/usr/share/java
