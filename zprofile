paths=(
    "$HOME/bin"
    "$HOME/.config/i3/bin"
    "$ANDROID_HOME/tools"
    "$GOBIN"
    "$HOME/.cabal/bin"
)
# set PATH so it includes user's private bin if it exists
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

if [[ -r $HOME/.java_setup ]]
then
    . $HOME/.java_setup
fi
