#!/bin/bash
# the OpenStack Personal Automation and Launch Suite

usage() {
    cat <<EOM
Usage:
$(basename $0)

~ ❀ ~

Welcome to the Open Stack Personal Automation and Launch Suite!
This is an interactive menu suite designed to help you efficiently perform common tasks using the OpenStack CLI.

~ ❀ ~

Before accessing the main menu, you will be guided through an interactive dialogue to input your OpenStack connection details.
You will need to provide the following information:
 ➤ your OpenStack username
 ➤ your OpenStack project (also called "tenant") name
 ➤ The path to your application credential file.
   This file can be downloaded from the Horizon Web UI under: Identity → Application Credentials
   Ensure that the roles selected include Reader or Member.
   The file is typically saved in: ~/.openstack/app-cred-<proj_name>-openrc.sh

~ ❀ ~

Key features:
➤ Settings Persistence: Your last settings (username, project, and credentials file) are saved in ~/.pals, so you won’t need to re-enter them each time.
➤ When specifying the credentials file path, you can use tab autocompletion and the ~ shortcut for your home directory. 
➤ Automatic Virtual Environment Creation: a virtual environment named $HOME/.virtualenvs/pals will be automatically created if it doesn't already exist.
➤ OpenStack Python Client Installation: if the OpenStack Python client is not already installed, it will be automatically installed within the virtual environmen.
EOM
    exit 0
}

# any option will do for getting help
[ $# -gt 0 ] && { usage; }

check_status() { [ $? -eq 0 ] && echo ✅ || { echo ❌;exit; } }

# Define the file path
PAL_FILE="$HOME/.pals"

# Check if the file exists
if [[ ! -f "$PAL_FILE" ]]; then
  echo "❀ File $PAL_FILE does not exist. Creating it with permissions 700..."
  # Create the file and add a basic YAML structure with groups and key-value pairs
  cat <<PALS > "$PAL_FILE"
# pals variables
openstack:
  username: groda
  project:
  app_cred:
PALS

  # Set file permissions to 700
  chmod 700 "$PAL_FILE"

  echo "❀ File $PAL_FILE created successfully."
else
  echo "❀ File $PAL_FILE already exists."
fi

PALS_ENV=pals
# activate environment
# Note: it's assumed that the virtual environment ~/.virtualenvs/${PALS_ENV} exists in the home-directory
if [ ! -f "$HOME/.virtualenvs/${PALS_ENV}/bin/activate" ]; then
  echo "Create new environment ${PALS_ENV}"
  virtualenv $HOME/.virtualenvs/${PALS_ENV}
fi

source $HOME/.virtualenvs/${PALS_ENV}/bin/activate

# install openstack client
pip install -r requirements.txt

# function for extracting value from simple YAML
get_value() {
awk -v pk="$2" -v ck="$3" -F'\n' '
{
if($0==pk":") 
  found=1 
else if (found && $0 !~ "^[[:space:]]+") 
  exit 
else if (found && $0 ~ "[[:space:]]+"ck":*") 
  {
   split($0,a," ")
   print(a[2])
   exit
  }
}
' $1
}

# function for setting value from simple YAML
set_value() {
awk -v pk="$2" -v ck="$3" -v v="$4" -F'\n' '
{
if($0==pk":")
  {
   found=1
   print $0
  }
else if (found && $0 !~ "^[[:space:]]+")
  {
   found=0
   print $0
  }
else if (found && $0 ~ "[[:space:]]+"ck":*")
  {
   split($0,a," ")
   a[2]="55"
   printf "  %s %s", a[1],v
   print("")
  }
else
  {
   print $0
  }
}
' $1
}

# Extract the value of username from the openstack group
USER=$(get_value $PAL_FILE 'openstack' 'username')
PROJ=$(get_value $PAL_FILE 'openstack' 'project')
APP_CRED=$(get_value $PAL_FILE 'openstack' 'app_cred')
#often: APP_CRED=$HOME/.openstack/app-cred-${PROJ}-openrc.sh

# backup
cat $PAL_FILE >>$PAL_FILE.bak

echo "The OpenStack username is the name used to log in to OpenStack"
read -p "Enter your OpenStack username (enter to keep default)  [$USER]: " NEW_USER 
if [ "$NEW_USER" != "" ];then
  USER=$NEW_USER 
  set_value $PAL_FILE 'openstack' 'username' $USER >$PAL_FILE.tmp && mv $PAL_FILE.tmp $PAL_FILE
fi

read -p "Enter your OpenStack project/tenant (enter to keep default)  [$PROJ]: " NEW_PROJ
if [ "$NEW_PROJ" != "" ];then
  PROJ=$NEW_PROJ 
  set_value $PAL_FILE 'openstack' 'project' $PROJ >$PAL_FILE.tmp && mv $PAL_FILE.tmp $PAL_FILE
fi

# Prompt the user with tab-completion enabled 
read -e -p "Enter the location of your application credentials file (enter to keep default)  [$APP_CRED]: " NEW_APP_CRED
if [ "$NEW_APP_CRED" != "" ];then
  # Safely expand tilde (~) using parameter expansion
  if [[ "$NEW_APP_CRED" == ~* ]]; then
    NEW_APP_CRED="${NEW_APP_CRED/#\~/$HOME}"
  fi
  APP_CRED=$NEW_APP_CRED
  set_value $PAL_FILE 'openstack' 'app_cred' $APP_CRED >$PAL_FILE.tmp && mv $PAL_FILE.tmp $PAL_FILE
fi


# unset all "OS*" variables
unset $(env | grep "^OS" |awk -F'=' '{print $1}')

# application credential file should be located in ~/.openstack/
#echo "Download your application credentials to  ~/.openstack/app-cred-${PROJ}-openrc.sh ..."
# in Horizon: Identity/Application Credentials/ Roles: reader/member
echo "Reading credentials file $APP_CRED ..."
echo "-->"$APP_CRED"<--"
#source ~/.openstack/app-cred-groda_ro-openrc.sh
source "$APP_CRED"

check_status

banner() {
    msg="❀ $* ❀"
    edge=$(echo "$msg" | sed 's/./❀/g')
    echo "$edge"
    echo "$msg"
    echo "$edge"
}

show_command() { banner $1; $1; }

show_user_info() {
  read -p "Enter your username (enter to keep default)  [$USER]: " USER
  if [ "$USER" != "" ];then
    openstack user show $USER
  else 
    openstack user show $PROJ
  fi
}


show_vm_hardware() {
  instance_list=$(openstack server list --format value --column ID --column Name --column Image)
  
  echo "Instance Name | Image ID | CPU Arch | Disk Bus | SCSI Model | OS Distro | OS Version"
  echo "------------------------------------------------------------------------------------"

  while IFS=" " read -r instance_id instance_name image_id; do
    if [[ "$image_id" != "" ]]; then
        image_properties=$(openstack image show "$image_id" -f json | jq -r '.properties | "\(.cpu_arch) \(.hw_disk_bus) \(.hw_scsi_model) \(.os_distro) \(.os_version)"')

        cpu_arch=$(echo "$image_properties" | awk '{print $1}')
        hw_disk_bus=$(echo "$image_properties" | awk '{print $2}')
        hw_scsi_model=$(echo "$image_properties" | awk '{print $3}')
        os_distro=$(echo "$image_properties" | awk '{print $4}')
        os_version=$(echo "$image_properties" | awk '{print $5}')

        echo "$instance_name | $image_id | $cpu_arch | $hw_disk_bus | $hw_scsi_model | $os_distro | $os_version"
    else
        echo "$instance_name |  No Image | N/A | N/A | N/A | N/A | N/A"
    fi
  done <<< "$instance_list"
}

# Display the menu and handle choices
while true; do
    clear
    echo "❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀"
    echo "  The Open Stack Personal Automation and Launch Suite  "
    echo "❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀"
    echo "1. Show Info on Project"
    echo "2. Show Info on User"
    echo "3. Show Projects I'm A Member Of"
    echo "4. Show All Instances"
    echo "5. Show Bare Metal"
    echo "6. Show All Images"
    echo "7. Show All Flavors"
    echo "8. Show Quotas"
    echo "9. Exit"
    echo "------------------------------------"
    
    # Read user input
    read -p "Enter your choice [1-9]: " choice
    
    # Execute the chosen command
    case $choice in
        1)
            echo "Show info on project $PROJ:"
            show_command "openstack project show $PROJ"
            ;;
        2)
            echo "Show info for user"
            show_user_info
            ;;
        3)
            echo "Show all projects I'm a member of"
            show_command "openstack project list"
            ;;
        4)
            echo "List servers in project $PROJ:"
            show_command "openstack server list -f table -c ID -c Name -c Status"
            ;;
        5)
            echo "Show Info on Hardware:"
            show_vm_hardware
            ;;
        6)
            echo "Show available images"
            show_command "openstack image list"
            ;;
        7)
            echo "Show available flavors, sort by RAM ascending"
            show_command "openstack flavor list --sort-column RAM --sort-ascending"
            ;;
        8)
            echo "Show quotas for project $PROJ"
            show_command "openstack quota show"
            ;;
        9|q)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid option, please choose a number between 1 and 9."
            ;;
    esac
    
    # Wait for the user to press a key before refreshing the menu
    read -p "Press any key to return to the menu..." -n1 -s
done

