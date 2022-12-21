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

#color response creators
function colorprint() {
    heading="$1\t"
    body="$2"
    printf '%b' "${heading}"
    printf '%b\n' "${body}${nc}" | do_the_wrap
}

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
port=""

if [ -z "$2" ];then
    echo_info "No port number was provided. Using 8080"
    port=8080
else
    port=$2
fi


logfile="$HOME/django_creator.log"

echo "" > $logfile

if ! command -v pip3 &> /dev/null
then
    if ! command -v pip &> /dev/null
    then
        echo "pip or pip3 could not be found"
        sleep 2
        exit 1
    fi
else
    pip=pip3
    python=python3
fi

#OS Detection
activation_path=''
echo_info 'Your operating system is '$OSTYPE
sleep 2
echo_progress_start "Changing paths for OS"
case "$OSTYPE" in
  darwin*)  activation_path='.env/bin/activate' ;;
  linux*)   activation_path='.env/bin/activate' ;;
  msys*)    activation_path='.env/Scripts/Activate' ;;
  cygwin*)  activation_path='.env/Scripts/Activate' ;;
  *)        echo_error "Path changing failed" ;;
esac
sleep 2
echo_success "Paths changed successfully"
###

echo_progress_start "Starting Django project creator..."

#Create Project Folder
echo_info "Created project folder: $project"
mkdir -p "$project"

cd "$project"

#Checking virtualenv installation
echo_progress_start "Checking virtualenv installation..."
if $pip show virtualenv >> $logfile; then
    echo_progress_done "virtualenv is already installed."
else
    echo_progress_start "virtualenv is not installed. Starting the installation..."
    if $pip install virtualenv >> $logfile; then
        echo_progress_done "Installed virtualenv."
    else
        echo_error "Installing virtualenv failed."
        sleep 2
        exit 1
    fi
fi

#Creating virtualenv installation
echo_progress_start "Creating virtualenv..."
if $python -m virtualenv .env >> $logfile; then
    echo_progress_done "Created virtualenv."
else
    echo_error "Creating virtualenv failed."
    sleep 2
    exit 1
fi

#Activating virtualenv installation
echo_progress_start "Activating virtualenv..."
if source $activation_path >> $logfile; then
    echo_progress_done "Activated virtualenv."
else
    echo_error "Activating virtualenv failed."
    sleep 2
    exit 1
fi

#Django installation
echo_progress_start "Installing Django..."
if $pip install django >> $logfile; then
    echo_progress_done "Installed Django."
else
    echo_error "Installing Django failed."
    sleep 2
    exit 1
fi

#Creating requirements.txt
echo_progress_start "Creating requirements.txt..."
if $pip freeze > "requirements.txt"; then
    echo_progress_done "Created requirements.txt."
    echo_info "List of the packages in this Django project:"
    cat "requirements.txt"
else
    echo_error "Creating requirements.txt failed."
    sleep 2
    exit 1
fi

#Creating Django project
echo_progress_start "Creating Django project 'main'..."
if django-admin startproject main . >> $logfile; then
    echo_progress_done "Created Django project."
else
    echo_error "Creating Django project failed."
    sleep 2
    exit 1
fi

#Creating Django Core Folder
echo_progress_start "Creating the app core"
if $python manage.py startapp core; then
    echo_progress_done "Created app core succesfully."
else
    echo_error "Creating app core failed"
    sleep 2
    exit 1
fi

#Creating Django Forms file
echo_progress_start "Creating forms.py"
if touch core/forms.py; then
    echo_progress_done "Created forms.py successfully"
else
    echo_error "Creating forms.py failed"
    sleep 2
    exit 1
fi

#Creating Template Directory
echo_progress_start "Creating template directory"
if mkdir core/templates; then
    echo_progress_done "Created template directory successfully"
else
    echo_error "Creating template directory failed"
    sleep 2
    exit 1
fi

#Creating Example Template
echo_progress_start "Creating sample index.html"
if cat << EOF > core/templates/index.html
<html>
  <head>
   <title>$project</title>
  </head>
  <body>
    <div class="container">
      <h1>Welcome to your Create Django App</h1>
    </div>
  </body>
</html>
EOF
then
    echo_progress_done "Created sample index.html successfully"
else
    echo_error "Creating index.html failed"
    sleep 2
    exit 1
fi

#Adding created app to the settings
echo_progress_start "Editing settings.py"
if sed -i "/django.contrib.staticfiles/a\    'main'," main/settings.py; then
    echo_progress_done "Editing settings.py successfully"
else
    echo_error "Editing settings file failed"
    sleep 2
    exit 1
fi

#Creating a Simple View
echo_progress_start "Create a simple view"
if sed -i "2d" core/views.py && sed -i "2c\from django.http import HttpResponse\n\n\n#def home(request):\n    #return HttpResponse('<h1>Welcome to the Django.</h1>')\n\n" core/views.py
    echo_progress_done "Created a simple view successfully"
then
    echo "def home(request):" >> core/views.py
    echo "    return render(request, 'index.html')" >> core/views.py
else
    echo_error "View creation failed"
    sleep 2
    exit 1
fi

#Complete Django Migration
echo_progress_start "Starting Django migration..."
if $python manage.py migrate >> $logfile; then
    echo_progress_done "Django migration is successful."
else
    echo_error "Django migration failed."
    sleep 2
    exit 1
fi

#Creating Django Superuser
echo_progress_start "Creating superuser..."
if $python manage.py createsuperuser; then
    echo_progress_done "Created superuser."
else
    echo_error "superuser creation failed."
    sleep 2
    exit 1
fi

#Adding .gitignore file
echo_progress_start "Downloading .gitignore for Django project..."
if curl "https://www.toptal.com/developers/gitignore/api/django" --output ".gitignore" >> $logfile 2>&1; then
    echo_progress_done "Downloaded .gitignore successfully."
else
    echo_error "Downloading .gitignore failed. Please make sure curl is installed."
    sleep 2
    exit 1
fi

sleep 2
echo_success "Django Project created successfully"
sleep 2

#Starting the Project
echo_info "Starting the Project Now"
if $python manage.py runserver $port; then
    echo ""
else
    echo_error "Project could not be started."
    exit 1
fi
deactivate
