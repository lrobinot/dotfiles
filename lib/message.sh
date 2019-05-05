# Colors
ESC_SEQ="\e["
COL_RESET=$ESC_SEQ"39m"
COL_RED=$ESC_SEQ"31m"
COL_GREEN=$ESC_SEQ"32m"
COL_YELLOW=$ESC_SEQ"33m"
COL_BLUE=$ESC_SEQ"34m"
COL_MAGENTA=$ESC_SEQ"35m"
COL_CYAN=$ESC_SEQ"36m"

function message() {
    echo -e "\n$COL_GREEN*** $1$COL_RESET" 
}

function ok() {
    echo -e "$COL_GREEN[ok]$COL_RESET "$1
}

function running() {
    echo -en "$COL_YELLOW ⇒ $COL_RESET"$1": "
}

function action() {
    echo -e "\n$COL_YELLOW[action]:$COL_RESET\n ⇒ $1..."
}

function warn() {
    echo -e "$COL_YELLOW[warning]$COL_RESET "$1
}

function error() {
    echo -e "$COL_RED[error]$COL_RESET "$1
}
