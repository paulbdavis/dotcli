[ ! "$LANG" = en_US.UTF8 ] && export LANG=en_US.UTF8

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
export GOPATH=${XDG_DATA_HOME:-$HOME/.local/share}/go
export GOBIN=$GOPATH/bin
export GO111MODULE=on
export GOARCH=amd64
export GOOS=linux

# android
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SWT=/usr/share/java

# set PATH so it includes user's private bin if it exists
paths=(
    "$HOME/bin"
    "$HOME/.local/bin"
    "$HOME/.yarn/bin"
    "$HOME/.config/i3/bin"
    "$HOME/.config/dwl/bin"
    "$ANDROID_HOME/tools"
    "$GOBIN"
    "$HOME/.cabal/bin"
    "$HOME/.cargo/bin"
    "$HOME/.krew/bin"
)
for dir in $paths
do
    if [ "${PATH/$dir//}" = "$PATH" ]
    then
        if [ -d "$dir" ]
        then
            export PATH="$dir:$PATH"
        fi
    fi
done

if which rustc >/dev/null 2>&1
then
    rust_root="$(rustc --print sysroot 2>/dev/null)"
    if [[ -n "$rust_root" ]]
    then
        export PATH="$rust_root/bin:$PATH"
        export RUST_SRC_PATH="$rust_root/lib/rustlib/src/rust/src"
    fi
fi
    
#############
# nvm setup #
#############

export NVM_DIR="$HOME/.nvm"
nvmfile=$NVM_DIR/nvm.sh
if [[ ! -s "$nvmfile" ]]
then
    nvmfile="/usr/share/nvm/init-nvm.sh"
fi
if [[ -s "$nvmfile" ]]
then
    which nvm >/dev/null 2>&1 || source $nvmfile
fi
    
default_ssh_auth_sock="/var${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.ssh"

if [[ -z "$SSH_AUTH_SOCK" && -e "$default_ssh_auth_sock" ]]
then
    export SSH_AUTH_SOCK="$default_ssh_auth_sock"
fi



# include any local env files

if [[ -d $HOME/.env.d ]]
then
    for envfile in $HOME/.env.d/*
    do
        . "$envfile"
    done
fi

if which direnv >/dev/null 2>&1
then
    eval "$(direnv export zsh 2>/dev/null)"
fi

# use breeze theme if present for qt apps
if [[ -f "/usr/lib/qt/plugins/styles/breeze.so" ]]
then
    export QT_STYLE_OVERRIDE=Breeze
fi

systemctl --user import-environment PATH
systemctl --user import-environment GOPATH
systemctl --user import-environment GOBIN
systemctl --user import-environment GO111MODULE
systemctl --user import-environment SSH_AUTH_SOCK
