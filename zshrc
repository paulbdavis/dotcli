# get zsh dir

zsh_dir="${ZDOTDIR:-$HOME}"

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
    if [[ ! -d "${zsh_dir}/.zsh" ]]
    then
        mkdir "${zsh_dir}/.zsh"
    fi

    for plugin in $plugins
    do
        gitURL="https://github.com/${plugin}.git"
        gitDest="${zsh_dir}/.zsh/plugins/${plugin#*/}"
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
fpath=($zsh_dir/.zsh/completions $fpath)
# more completions
# from https://github.com/zsh-users/zsh-completions
fpath=($zsh_dir/.zsh/plugins/zsh-completions/src $fpath)

if [[ -f "$HOME/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/share/zsh/site-functions/_cargo" ]]
then
    fpath=("$HOME/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/share/zsh/site-functions" $fpath)
fi

compinit

if which npm >/dev/null 2>&1
then
    source <(npm completion 2>/dev/null)
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

if which helm >/dev/null
then
    source <(helm completion zsh)
fi

if which kops >/dev/null
then
    source <(kops completion zsh)
fi

gcloud_comp=/opt/google-cloud-sdk/completion.zsh.inc
if [[ -f $gcloud_comp ]]
then
    source $gcloud_comp
fi


#########
# marks #
#########

export MARKPATH=${XDG_DATA_DIR:-$HOME/.local/share}/shell-marks

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
# from bashrc #
###############

# put ls colors in an external file, because it is annoying
if [[ -f $zsh_dir/.zsh/ls-colors.zsh ]]
then
    source $zsh_dir/.zsh/ls-colors.zsh
fi
export EDITOR="emacsclient"

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

alias zs='source $zsh_dir/.zshrc'

PLATFORM=$(uname -s)
# ls and tree
if [[ "$PLATFORM" = "Linux" ]]
then
    if which exa >/dev/null 2>&1
    then
        exa_base='exa -h -m -l -F --time-style long-iso --git --group-directories-first'
        alias ls="$exa_base"
        alias ll="$exa_base -u -U -g -H -i -S -@"
        alias la="$exa_base -a"
        alias lt="$exa_base -T"
        alias lg="$exa_base --git-ignore"
    else
        alias ls='ls -lhF --color --group-directories-first'
        alias la='ls -lhfaF --color --group-directories-first'
        alias ll='ls -lhfaF --color --group-directories-first'
    fi
elif [[ "$PLATFORM" = "Darwin" ]]
then
    alias ls='ls -lhFG'
    alias la='ls -lhfaG'
    alias ll='ls -aF'
fi

alias greplb='grep -e --line-buffered --'

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
    alias btc=bitcoin-cli
    compdef btc=bitcoin-cli
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
    echo -n $text | xclip -selection primary
    echo -n $text | xclip -selection secondary
    echo -n $text | xclip -selection clipboard
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
source $zsh_dir/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
export ZSH_AUTOSUGGEST_STRATEGY=("match_prev_cmd" "history")
export ZSH_AUTOSUGGEST_USE_ASYNC="t"
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"

##################
# misc functions #
##################

function getusername {
    curlData="$(curl -s 'https://jimpix.co.uk/words/random-username-generator.asp' -X POST --data 'go=yes&ul1=1&ul2=4&al=0')"
    nodes="$(echo $curlData | grep 'href=.check\.asp')"
    namelist="$(echo $nodes | sed 's/.*u=\([a-zA-Z0-9.]*\).*/\1/')"
    if [[ "$1" == "-l" ]]
    then
        echo "$namelist"
    else
        username="$(echo "$namelist" | head -1 | tr -d '\n')"
        echo -n $username | copy
        echo $username
    fi
}

function termcolors {
    for i in {0..255} ; do
        printf "\x1b[48;5;%sm%3d\e[0m " "$i" "$i"
        if (( i == 15 )) || (( i > 15 )) && (( (i-15) % 6 == 0 )); then
            printf "\n";
        fi
    done

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

# directory sync for emacs vterm
vterm_prompt_end() {
    printf "\e]51;A$(whoami)@$(hostname):$(pwd)\e\\";
}

precmd () {
    print -Pn "\e]0;$termTitle\a"
    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]]
    then
        branchformat='%F{blue}%b%c%u%f'
    else
        branchformat="%F{blue}%b%c%u %F{red}U%f"
    fi
    branchformat="%f${branchformat} %F{red}%7.7i%f"

    zstyle ':vcs_info:*' formats " ${branchformat}%{$fg_bold[white]%}"

    isProdServer=""
    if [[ -n "$THIS_IS_A_FUCKING_PROD_SERVER" ]]
    then
        isProdServer="
%F{red}THIS IS A FUCKING PRODUCTION SERVER, BE CAREFUL%f"
    fi

    promptSplit="
"
    PS1='

%(!.%F{red}.%{$fg_no_bold[yellow]%})%n%{$fg_no_bold[green]%}@%{$fg_no_bold[cyan]%}%2m %{$fg_bold[yellow]%} %{$fg_no_bold[blue]%}%3~${promptSplit}%{$fg_no_bold[white]%}%D{%Y-%m-%d %H:%M %Z} %F{magenta}%h%f %(?.%F{green}✓.%F{red}✗) %{$fg_bold[magentaii]%}${vcs_info_msg_0_}${isProdServer}${promptSplit}${runningSSH}$(_vimode_color)%B%#%b%f%{$(vterm_prompt_end)%} '
    vcs_info
}

preexec() {
    # echo -ne "\033]12;grey\007"
    # echo -ne "\033[2 q"
}

################
# local config #
################

LOCALFILE="$zsh_dir/.zshrc.local"
if [[ -f "$LOCALFILE" ]]
then
    source "$LOCALFILE"
fi

####################
# syntax highlight #
####################

# syntax highlighing on prompt
# from https://github.com/zsh-users/zsh-syntax-highlighting
source $zsh_dir/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=red"
export ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=magenta"

###########
# history #
###########

HISTFILE=~/.zhistory
HISTSIZE=10000
SAVEHIST=10000
setopt appendHistory
setopt shareHistory
setopt histIgnoreAllDups
bindkey "^R" history-incremental-search-backward


# fish like history search, must load AFTER syntax highlighting
source $zsh_dir/.zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# make the search fuzzy
export HISTORY_SUBSTRING_SEARCH_FUZZY=t
# change colors
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="fg=blue,bold,underline"
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND="fg=red,bold,underline"

# OPTION 3: for Ubuntu 12.04, Fedora 21, and MacOSX 10.9
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

## EMACS mode ###########################################

bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down


# play crawl :)

crawl_key_file="$HOME/.ssh/crawl_cbro_key"

function webcrawl () {
    
    if [[ ! -f "$crawl_key_file" ]]
    then
        curl -s http://crawl.berotato.org/crawl/keys/cbro_key > "$crawl_key_file"
        chmod 600 "$crawl_key_file"
    fi
    TERM=xterm-256color ssh -i "$crawl_key_file" crawler@crawl.berotato.org
}

# load direnv
if which direnv >/dev/null 2>&1
then
    _direnv_hook() {
        eval "$(direnv export zsh 2>/dev/null)";
    }
    typeset -ag precmd_functions;
    if [[ -z ${precmd_functions[(r)_direnv_hook]} ]]; then
        precmd_functions+=_direnv_hook;
    fi

fi

# update gpg agent
if which gpg-connect-agent >/dev/null 2>&1
then
    gpg-connect-agent updatestartuptty /bye >/dev/null
fi

