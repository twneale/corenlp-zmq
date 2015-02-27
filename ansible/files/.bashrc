# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=10000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi


#--------------------------------------------------------------------------
# My stuff.
#--------------------------------------------------------------------------

export EDITOR=/usr/bin/nano

# Identify my python startup script.
export ROOT_PYTHONSTARTUP="$HOME/.pythonrc"
export PYTHONSTARTUP=$ROOT_PYTHONSTARTUP

# Add .bin to my path.
PATH="$PATH:$HOME/.bin"

# Configure virtualenv aliases.
source /usr/local/bin/virtualenvwrapper.sh
export WORKON_HOME=~/.virtualenvs
export PROJECT_HOME=~/projects

# Git prompt and completion.
source ~/.git-prompt.sh
source ~/.git-completion.bash
export GIT_PS1_SHOWDIRTYSTATE=true
export PS1='\[\033[32m\]\[\033[00m\]:[\[\033[1;32m\]\u@\h\[\033[00m\]] \[\033[34m\]\w\[\033[31m\]$(__git_ps1)\[\033[00m\]\$ '

if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && \
      eval "$(dircolors -b ~/.dircolors)" || \
      eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
fi

alias gs='git status'
alias gc='git commit'
alias gd='git diff'
alias gdc='git diff --cached'
alias gk='git checkout'
alias gb='git branch'
alias gkm='git checkout master'
alias ga='git add'
alias gap='git add -p'
alias gl='git log'
alias ts='tree -l'
alias td='tree -d'
alias pdb='python -m pdb'
alias pudb='python -m pudb'
alias ack=ack-grep
alias nb='nano ~/.bashrc'
alias sb='source ~/.bashrc'
alias wifioff='nmcli nm wifi off'
alias wifion='nmcli nm wifi on'

export SL=~/sunlight
alias sl='cd $SL'
export PR=~/projects
alias pr='cd $PR'
export CO=~/code
alias co='cd $CO'
export VE=~/.virtualenvs
alias ve='cd $VE'
export CS=~/casetext
alias cs='cd $CS'
export DL=~/Downloads
alias dl='cd $DL'
export DR=~/Dropbox
alias dr='cd $DR'


export DENDRITE_DATA=$PR/dendrite/data
alias dd='cd $DENDRITE_DATA'

alias p=python
alias b=bpython
alias i=ipython

alias ccat='pygmentize -g'

function json {
  cat $1 | python -m json.tool | less
  }

function xml {
  xmllint -format - < $1 | less
  }

function gr {
  grep -r $1 .
  }


alias proxy='ssh -fC2qTnN -L 9001:localhost:8888 thom@bee'
function pyc () {
        find . -type f -name "*.py[co]" -delete
        find . -type d -name "__pycache__" -delete
}

function md {
  if [ ! -n "$1" ]; then
    echo "Enter a directory name"
  elif [ -d $1 ]; then
    echo "\`$1' already exists"
  else
    mkdir $1 && cd $1
  fi
}

function fn () {
    find . -name $1
}

#----------------------------------------------------------------------------
# Compatible with ranger 1.4.2 through 1.6.*
#
# Automatically change the directory in bash after closing ranger
#
# This is a bash function for .bashrc to automatically change the directory to
# the last visited one after ranger quits.
# To undo the effect of this function, you can type "cd -" to return to the
# original directory.

function ranger-cd {
    tempfile='/tmp/chosendir'
    /usr/bin/ranger --choosedir="$tempfile" "${@:-$(pwd)}"
    test -f "$tempfile" &&
    if [ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]; then
        cd -- "$(cat "$tempfile")"
    fi
    rm -f -- "$tempfile"
}

# This binds Ctrl-O to ranger-cd:
alias rr='ranger-cd'
#export JAVA_HOME=/usr/lib/jvm/java-1.5.0-sun-1.5.0.13/
export JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64/
export PATH=$PATH:/usr/lib/jvm/java-1.5.0-sun-1.5.0.13/bin/

# I just put this puppy in my .bashrc.
# Usage:
#  - pin           # equivalent to "touch __init__.py"
#  - pin some/dir  # equivalent to "touch some/dir/__init__.py"
#
# Thanks to paultag for lending me his bash chops.
#
function pin { if [ "x$1" = "x" ]; then DIR="./"; else DIR="$1"; fi; touch ${DIR}/__init__.py; }

function killport {
  lsof -i tcp:$1 | awk 'NR!=1 {print $2}' | xargs kill 
}

[[ -s $HOME/.nvm/nvm.sh ]] && . $HOME/.nvm/nvm.sh

# Set project dir in a virtualenv.

function setproj {
    echo "setting project dir to ":$PWD
    echo $PWD > $VIRTUAL_ENV/.project
}

export SUNLIGHT_API_KEY=323974e35f9a48a19b09b16562709589
export ASAMENDED_USER_KEY=b006a3d687bde0befc7b92001e723fde

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
source ~/.rvm/scripts/rvm


# Casetext credentials.
export CTFOB=/media/thom/CTFOB
function tcmount {
    credentials_dir=~/.credentials
    truecrypt -t --protect-hidden=no --fs-options="umask=277" $CTFOB/credentials.truecrypt $credentials_dir
}

function tcumount {
    credentials_dir=~/.credentials
    truecrypt -t -d $CTFOB/credentials.truecrypt
}


