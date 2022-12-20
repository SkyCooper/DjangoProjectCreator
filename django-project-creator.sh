#!/bin/bash

bell="true"       # Whether or not Warning and Error should trigger the bell
fold="true"       # Whether or not to apply line wrapping to terminal for indentation
full_width="true" # Whether output should be as wide as the terminal. Setting to false will still wrap when terminal is less than default width
width_cap="140"   # Applies when full-width is false. If terminal has less cols then this, the max terminal width is used.

# colours
red=$(tput setaf 1 || tput AF 1)
green=$(tput setaf 2 || tput AF 2)
yellow=$(tput setaf 3 || tput AF 3)
blue=$(tput setaf 4 || tput AF 4)
magenta=$(tput setaf 5 || tput AF 5)
cyan=$(tput setaf 6 || tput AF 6)

# reset
nc="$(tput sgr0)"

# modifiers
bold=$(tput bold || tput md) # Start boldrbold="\e[21m"
dim=$(tput dim)              # Start dim
rdim="\e[22m"
under=$(tput smul || tput us)   # Start under
runder=$(tput rmul || tput ue)  # End   under
italic=$(tput sitm || tput ZH)  # Start italic
eitalic=$(tput ritm || tput ZR) # End   italic
stout=$(tput smso || tput so)   # Start stand-out
estout=$(tput rmso || tput se)  # End stand-out

function ring_the_bell() {
    [[ $bell == "true" ]] && tput bel
}

function echo_warn() {
    ring_the_bell
    colorprint "${yellow}${bold}WARN" "$1"
}

function echo_error() {
    ring_the_bell
    colorprint "${red}${bold}ERROR" "$1"
}

function echo_info() {
    colorprint "${bold}INFO" "$1"
}

function echo_progress_start() {
    colorprint "${dim}..." "$1"
}

function echo_progress_done() {
    if [[ -z $1 ]]; then
        message="Done"
    else
        message="$1"
    fi
    colorprint "" "${green}${dim}\u2714   ${italic}$message"
}

function echo_success() {
    colorprint "${green}${bold}SUCCESS" "$1"
}

function echo_query() {
    colorprint "${blue}${bold}INPUT" "${italic}$1"
    if [[ -n $2 ]]; then
        options="($2) "
    else
        options=""
    fi
    echo -en "${blue}${bold}${options}>${nc} "
}

function colorprint() {
    heading="$1\t"
    body="$2"
    printf '%b' "${heading}"
    printf '%b\n' "${body}${nc}" | do_the_wrap

}

# Wraps indents the text according to variables / terminal output
function do_the_wrap() {
    if [[ $fold = true ]]; then
        # width to use for folding and wrapping (excludes tab for indentation, subtract 8 char to account for that)
        width=$(tput cols)
        if [[ $full_width == "false" ]]; then
            if [[ $width -gt $width_cap ]]; then
                width=$width_cap
            fi
        fi
        width=$((width - 8))
        fold -s -w${width} | sed -e '2,$s/^/\t/'
    else
        cat
    fi
}

########################################
#          DO NOT CHANGE ABOVE         #
########################################

pip=pip
python=python

project=$1
port=$2

logfile="$HOME/django_creator.log"

echo "" > $logfile

if ! command -v pip3 &> /dev/null
then
    if ! command -v pip &> /dev/null
    then
        echo "pip or pip3 could not be found"
        exit 1
    fi
else
    pip=pip3
    python=python3
fi


echo_progress_start "Starting Django project creator..."

echo_info "Created project folder: $project"
mkdir -p "$project"

cd "$project"

echo_progress_start "Checking virtualenv installation..."
if $pip show virtualenv >> $logfile; then
    echo_progress_done "virtualenv is already installed."
else
    echo_progress_start "virtualenv is not installed. Starting the installation..."
    if $pip install virtualenv >> $logfile; then
        echo_progress_done "Installed virtualenv."
    else
        echo_error "Installing virtualenv failed."
        exit 1
    fi
fi

echo_progress_start "Creating virtualenv..."
if $python -m virtualenv .env >> $logfile; then
    echo_progress_done "Created virtualenv."
else
    echo_error "Creating virtualenv failed."
    exit 1
fi

echo_progress_start "Activating virtualenv..."
if source .env/bin/activate >> $logfile; then
    echo_progress_done "Activated virtualenv."
else
    echo_error "Activating virtualenv failed."
    exit 1
fi

echo_progress_start "Installing Django..."
if $pip install django >> $logfile; then
    echo_progress_done "Installed Django."
else
    echo_error "Installing Django failed."
    exit 1
fi

echo_progress_start "Creating requirements.txt..."
if $pip freeze > "requirements.txt"; then
    echo_progress_done "Created requirements.txt."
    echo_info "List of the packages in this Django project:"
    cat "requirements.txt"
else
    echo_error "Creating requirements.txt failed."
    exit 1
fi

echo_progress_start "Creating Django project 'main'..."
if django-admin startproject main . >> $logfile; then
    echo_progress_done "Created Django project."
else
    echo_error "Creating Django project failed."
    exit 1
fi

echo_progress_start "Starting Django migration..."
if $python manage.py migrate >> $logfile; then
    echo_progress_done "Django migration is successful."
else
    echo_error "Django migration failed."
    exit 1
fi

echo_progress_start "Creating superuser..."
if $python manage.py createsuperuser; then
    echo_progress_done "Created superuser."
else
    echo_error "superuser creation failed."
    exit 1
fi

echo_progress_start "Downloading .gitignore for Django project..."
if curl "https://www.toptal.com/developers/gitignore/api/django" --output ".gitignore" >> $logfile 2>&1; then
    echo_progress_done "Downloaded .gitignore successfully."
else
    echo_error "Downloading .gitignore failed. Please make sure curl is installed."
    exit 1
fi

deactivate

echo_success "Created Django project."
echo ""
echo_info "Use following commands to start your project:"
echo ""
echo_info "cd $project"
echo_info "source .env/bin/activate"

echo_info "$python manage.py runserver $port"
