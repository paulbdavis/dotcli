###############
# environment #
###############

if [[ "$TERM" == "dumb" ]]
then
    unsetopt zle
    unsetopt prompt_cr
    unsetopt prompt_subst
    PS1='$ '
    return
fi

[ ! "$LANG" = en_US.UTF8 ] && export LANG=en_US.UTF8

if [[ -d $HOME/.env.d ]]
then
    for envfile in $HOME/.env.d/*
    do
        . "$envfile"
    done
fi

############
# terminal #
############

# only set xterm-256color when we are sure we are using a color terminal
if [[ "$COLORTERM" == "gnome-terminal" ]] || [[ "$COLORTERM" == "xfce4-terminal" ]]
then
    export TERM=xterm-256color
fi

# if on linux tty, set up nicer colors
if [[ "$TERM" == "linux" ]]
then
    # black
    echo -en "\e]P0131313"
    # dark grey
    echo -en "\e]P83f3f3f"
    # red
    echo -en "\e]P1bc8383"
    echo -en "\e]P9cc9393"
    # green
    echo -en "\e]P25f7f5f"
    echo -en "\e]P107f9f7f"
    # yellow
    echo -en "\e]P3e0cf9f"
    echo -en "\e]P11f0dfaf"
    # blue
    echo -en "\e]P47cb8bb"
    echo -en "\e]P128cd0d3"
    # magenta
    echo -en "\e]P5bca3a3"
    echo -en "\e]P3#c0bed1"
    # cyan
    echo -en "\e]P6dfaf8f"
    echo -en "\e]P14dfaf8f"
    # light grey
    echo -en "\e]P7dcdccc"
    # white
    echo -en "\e]P15ffffff"
fi

################
# plugin setup #
################

plugins=(zsh-users/zsh-completions \
             zsh-users/zsh-syntax-highlighting \
             zsh-users/zsh-autosuggestions \
             zsh-users/zsh-history-substring-search)

# only do this if git is installed
if [[ -n "$(which git)" ]]
then
    if [[ ! -d "$HOME/.zsh" ]]
    then
        mkdir "$HOME/.zsh"
    fi

    for plugin in $plugins
    do
        gitURL="https://github.com/${plugin}.git"
        gitDest="$HOME/.zsh/plugins/${plugin#*/}"
        if [[ ! -d "$gitDest" ]]
        then
            echo "cloning repo"
            git clone $gitURL $gitDest
        fi
    done
fi


##############
# completion #
##############
zstyle ':completion:*' completer _complete _ignored _correct _approximate
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' menu select=long
zstyle ':completion:*' prompt 'Um......'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle :compinstall filename '/home/paul/.zshrc'

zmodload zsh/complist
autoload -Uz compinit
setopt extendedglob
fpath=($HOME/.zsh/completions $fpath)
# more completions
# from https://github.com/zsh-users/zsh-completions
fpath=($HOME/.zsh/plugins/zsh-completions/src $fpath)

if [[ -f "$HOME/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/share/zsh/site-functions/_cargo" ]]
then
    fpath=("$HOME/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/share/zsh/site-functions" $fpath)
fi

compinit

if which npm >/dev/null 2>&1
then
    source <(npm completion)
fi

aws_cli_comp=/usr/bin/aws_zsh_completer.sh
if [[ -f $aws_cli_comp ]]
then
    source $aws_cli_comp
fi

if which kubectl >/dev/null
then
    source <(kubectl completion zsh)
fi
    
gcloud_comp=/opt/google-cloud-sdk/completion.zsh.inc
if [[ -f $gcloud_comp ]]
then
    source $gcloud_comp
fi


#########
# marks #
#########

export MARKPATH=$HOME/.marks

function jump {
    cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark"
}

function mark {
    mkdir -p "$MARKPATH"
    ln -s "$(pwd)" "$MARKPATH/$1"
}

function unmark {
    rm -i "$MARKPATH/$1"
}

function marks {
    ls -l "$MARKPATH" | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/\t-/g' && echo
}

function _completemarks {
    reply=($(ls $MARKPATH))
}

compctl -K _completemarks jump
compctl -K _completemarks unmark

##########
# docker #
##########

function _dockr {
    reply=("clean" "cleanimages" "viz" "ip")
}

compctl -K _dockr dockr

##################
# vi keybindings #
##################
# bindkey -v
# jk for vim escape
# bindkey -M viins 'jk' vi-cmd-mode
# :wq for ecexute
# bindkey -M vicmd -r ':'
# bindkey -M vicmd ':wq' accept-line
# bindkey -M vicmd ':w' accept-line
# allow deletion over newlines and past insert point
# bindkey "^?" backward-delete-char
# bindkey "^H" backward-delete-char

WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

bindkey -e


###############
# tetris, duh #
###############

autoload -U tetris
zle -N tetris
bindkey "^T" tetris

###############
# from bashrc #
###############

# put ls colors in an external file, because it is annoying
if [[ -f $HOME/.zsh/ls-colors.zsh ]]
then
    source $HOME/.zsh/ls-colors.zsh
fi
export EDITOR="vim"

# alias less='/usr/share/vim/vim73/macros/less.sh'
# colors for less
export LESS="-R"
export LESS_TERMCAP_me=$(printf '\e[0m')
export LESS_TERMCAP_se=$(printf '\e[0m')
export LESS_TERMCAP_ue=$(printf '\e[0m')
export LESS_TERMCAP_mb=$(printf '\e[1;32m')
export LESS_TERMCAP_md=$(printf '\e[1;34m')
export LESS_TERMCAP_us=$(printf '\e[1;32m')
export LESS_TERMCAP_so=$(printf '\e[1;44;1m')
export LESSOPEN="| /usr/bin/source-highlight-esc.sh %s"

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

###########
# aliases #
###########

alias zs='source $HOME/.zshrc'

PLATFORM=$(uname -s)
# ls and tree
if [[ "$PLATFORM" = "Linux" ]]
then
    alias ls='ls -lhF --color'
    alias la='ls -lhfa --color'
    alias ll='ls -aF'
elif [[ "$PLATFORM" = "Darwin" ]]
then
    alias ls='ls -lhFG'
    alias la='ls -lhfaG'
    alias ll='ls -aF'
fi

alias tree='tree -ChF'

alias extip='dig +short myip.opendns.com @resolver1.opendns.com'

#color for grep
alias grep='grep --color'

alias google-chrome='google-chrome --audio-buffer-size=2048'
alias chromium='chromium --audio-buffer-size=2048'

if which bitcoin-cli >/dev/null 2>&1
then
    alias bitcoin=bitcoin-cli
    compdef bitcoin=bitcoin-cli
fi

# password gen
alias password-gen="echo 'running apg' && echo && apg"

# alias for backing up home folder
alias homebackup='rsync -av --include-from $HOME/.rsync-include --exclude "*" $HOME/'

# pass aliases to sudo
alias sudo='sudo '

# some git shit
g() {
    if [[ -z "$1" ]]
    then
        git status
    else
        git $*
    fi
}

alias gl='git la'
alias gp='git push'
alias gf='git fetch'
alias gls='git ls-files'
compdef g=git
alias gprojects='dirname */.git'
# compctl -K _git g


# xclip
copy() {
    text=$(cat)
    echo $text | xclip -selection primary
    echo $text | xclip -selection secondary
    echo $text | xclip -selection clipboard
}




if [[ $FBTERM -eq 1 ]]
then
    export TERM=fbterm
fi


#######
# zle #
#######

zle_highlight=(suffix:fg=red)

zle-line-init() {
    # zle -K viins
    # echo -ne "\033]12;lightblue\007"
    # echo -ne "\033[6 q"
}
zle-keymap-select() {
    if [ $KEYMAP = vicmd ]; then
        # echo -ne "\033]12;grey\007"
        # echo -ne "\033[2 q"
    else
        # echo -ne "\033]12;lightblue\007"
        # echo -ne "\033[6 q"
    fi
    if [[ -z $BUFFER && $KEYMAP == vicmd ]]
    then
        BUFFER=" "
        BUFFER=""
    fi
    zle reset-prompt
}

_pd-fortune() {
    zle -M "$(fortune -a | sed 's/\t/  /g')"
}

_pd-gitStatus() {

    gitStatus="$(git status 2>/dev/null | sed 's/\t/  /g')"
    if [ -z $gitStatus ]
    then
        gitStatus="Not a git repo"
    fi
    zle -M $gitStatus
}

zle -N zle-line-init
zle -N zle-keymap-select



# fish like suggestions
source $HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
export ZSH_AUTOSUGGEST_STRATEGY=match_prev_cmd
export ZSH_AUTOSUGGEST_USE_ASYNC=t
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=fg=black,bold

##################
# misc functions #
##################

function getusername {
    curlData="$(curl -s 'http://jimpix.co.uk/words/random-username-generator.asp#username-results' -X POST --data 'go=yes&ul1=1&ul2=4&al=0')"
    nodes="$(echo $curlData | grep 'href=.check\.asp')"
    nameslist="$(echo $nodes | sed 's/.*u=\([a-zA-Z0-9]*\).*/\1/')"
    if [[ "$1" == "-l" ]]
    then
        echo "$namelist"
    else
        echo "$namelist" | head -1 | copy
    fi
}

#########################
# vi detector functions #
#########################

_vimode() {
    text="${${KEYMAP/vicmd/<<<}/(main|viins)/}"
    echo -n "%F{red}$text%f"

}

_vimode_color() {
    if [[ "$KEYMAP" == "vicmd" ]]
    then
        echo -n '%F{red}'
    else
        echo -n '%f'
    fi
}

############
# vcs info #
############

autoload -Uz vcs_info
zstyle ':vcs_info:*' stagedstr '%F{green} S'
zstyle ':vcs_info:*' unstagedstr '%F{yellow} C'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' actionformats "${branchformat} %F{blue}(%F{red}%a%F{blue})"
zstyle ':vcs_info:*' enable git svn hg
zstyle ':vcs_info:git*:*' get-revision true


##########
# prompt #
##########

autoload -U promptinit
promptinit
autoload -U colors && colors
setopt prompt_subst


runningSSH="%f "
if [ "$SSH_CONNECTION" ]
then
    runningSSH="%F{red}ssh %f "
fi

####################
# speial functions #
####################
termTitle='%n@%m: %~'

set-title () {
    termTitle=$1
}

precmd () {
    print -Pn "\e]0;$termTitle\a"
    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]]
    then
        branchformat='%F{blue}%b%c%u%f'
    else
        branchformat="%F{blue}%b%c%u %F{red}U%f"
    fi
    branchformat="%{$fg_no_bold[yellow]%}%s %f${branchformat} %F{red}%7.7i%f"

    zstyle ':vcs_info:*' formats "
[ ${branchformat}%{$fg_bold[white]%} ]"

    promptSplit="
"
    PS1='

%(!.%F{red}.%{$fg_no_bold[yellow]%})%n%{$fg_no_bold[green]%}@%{$fg_no_bold[cyan]%}%2m %{$fg_bold[white]%}-[ %{$fg_no_bold[blue]%}%3~%{$fg_bold[white]%} ]-${vcs_info_msg_0_}${promptSplit}%{$fg_no_bold[white]%}%W %T %F{magenta}%h%f %(?.%F{green}✓.%F{red}✗)${promptSplit}${runningSSH}$(_vimode_color)%B%#%b%f '
    vcs_info
}

preexec() {
    # echo -ne "\033]12;grey\007"
    # echo -ne "\033[2 q"
}

################
# local config #
################

LOCALFILE="$HOME/.zshrc.local"
if [[ -f "$LOCALFILE" ]]
then
    source "$LOCALFILE"
fi

####################
# syntax highlight #
####################

# syntax highlighing on prompt
# from https://github.com/zsh-users/zsh-syntax-highlighting
source $HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=red"
export ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=magenta"

###########
# history #
###########

HISTFILE=~/.zhistory
HISTSIZE=1000
SAVEHIST=1000
setopt appendHistory
setopt shareHistory
setopt histIgnoreAllDups
bindkey "^R" history-incremental-search-backward
bindkey -M vicmd "^R" history-incremental-search-backward


# fish like history search, must load AFTER syntax highlighting
source $HOME/.zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# make the search fuzzy
export HISTORY_SUBSTRING_SEARCH_FUZZY=t
# change colors
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="fg=blue,bold,underline"
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND="fg=red,bold,underline"

# OPTION 1: for most systems
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# OPTION 2: for iTerm2 running on Apple MacBook laptops
zmodload zsh/terminfo
bindkey "$terminfo[cuu1]" history-substring-search-up
bindkey "$terminfo[cud1]" history-substring-search-down

# OPTION 3: for Ubuntu 12.04, Fedora 21, and MacOSX 10.9
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

## EMACS mode ###########################################

bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

## VI mode ##############################################

bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

