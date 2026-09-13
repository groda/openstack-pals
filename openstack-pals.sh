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
 ➤ The path to your clouds.yaml file containing application credentials.
   This file can be downloaded from the Horizon Web UI under: Identity → Application Credentials
   Ensure that the roles selected include Reader or Member.
 ➤ your OpenStack project (it is one of the "clouds" in clouds.yml)

~ ❀ ~

Key features:
➤ Automatic Virtual Environment Creation: a virtual environment named $HOME/.virtualenvs/pals will be automatically created if it doesn't already exist.
➤ OpenStack Python Client Installation: if the OpenStack Python client is not already installed, it will be automatically installed within the virtual environment.
➤ When specifying the clouds.yaml file path, you can use tab autocompletion and the ~ shortcut for your home directory.
➤ Viewing the commands to be executed helps you memorize them.
EOM
    exit 0
}

# any option will do for getting help
[ $# -gt 0 ] && { usage; }

check_status() {
    [ $? -eq 0 ] && echo ✅ || { echo ❌; exit; }
}


echo "❀ Creating environment ..."
PALS_ENV=pals
VENV_PATH="$HOME/.virtualenvs/${PALS_ENV}"

# Create the virtual environment if it doesn't exist
if [ ! -d "${VENV_PATH}" ] || [ ! -f "${VENV_PATH}/bin/activate" ]; then
    echo "Creating new environment ${PALS_ENV}..."
    uv venv "${VENV_PATH}" --python 3.11
fi

# Activate it
source "${VENV_PATH}/bin/activate"

# Install requirements
echo "❀ Installing requirements ..."
uv pip install -r requirements.txt -q

# Check if openstack command is available
if ! command -v openstack >/dev/null 2>&1; then
    echo "❌ Error: 'openstack' command not found after installation."
    echo "Please check the requirements.txt or try reinstalling with:"
    echo "   uv pip install --force-reinstall python-openstackclient"
    exit 1
fi

echo "✅ Environment activated and ready!"

# Prompt user for clouds.yaml location with tab completion
CLOUDS_YAML=./clouds.yaml
read -e -p "Enter the location of your clouds.yaml file (enter to keep default) [$CLOUDS_YAML]: " NEW_CLOUDS_YAML

if [ "$NEW_CLOUDS_YAML" != "" ]; then
    # Safely expand tilde (~)
    if [[ "$NEW_CLOUDS_YAML" == ~* ]]; then
        NEW_CLOUDS_YAML="${NEW_CLOUDS_YAML/#\~/$HOME}"
    fi
    CLOUDS_YAML=$NEW_CLOUDS_YAML
fi

# Check if file exists
if [ ! -f "$CLOUDS_YAML" ]; then
    echo "❌ Error: clouds.yaml file not found at $CLOUDS_YAML"
    exit 1
fi

echo "✅ Using clouds.yaml: $CLOUDS_YAML"


# Extract cloud names from clouds.yaml using yq
# Extract cloud names as array (works on older Bash)
if yq --version 2>&1 | grep -q 'mikefarah/yq'; then
    # Mike Farah yq v4
    mapfile -t CLOUDS_LIST < <(
        yq e '.clouds | keys | .[]' "$CLOUDS_YAML"
    )
else
    # Python yq
    mapfile -t CLOUDS_LIST < <(
        yq '.clouds | keys | .[]' "$CLOUDS_YAML"
    )
fi

if [ ${#CLOUDS_LIST[@]} -eq 0 ]; then
    echo "❌ No clouds found or yq not available"
    exit 1
else
    echo "Available clouds: ${CLOUDS_LIST[*]}"
fi

# unset all "OS*" variables
unset $(env | grep "^OS" | awk -F'=' '{print $1}')

export OS_CLOUD=${CLOUDS_LIST[0]}

read -p "Enter your OpenStack cloud (enter to keep default) [$OS_CLOUD]: " NEW_PROJ

if [ "$NEW_PROJ" != "" ]; then
    export OS_CLOUD=$NEW_PROJ
fi

PROJECT_ID=$(openstack token issue -f value -c project_id 2>/dev/null)
echo "Project ID from token: $PROJECT_ID"


banner() {
    msg="❀ $* ❀"
    edge=$(echo "$msg" | sed 's/./❀/g')
    echo "$edge"
    echo "$msg"
    echo "$edge"
}

show_command() {
    banner "$1"
    read -ra command <<< "$1"
    "${command[@]}" | less -F
}

enter_command() {
    read -e -p "Command to run [e.g. openstack project list]: " CMD
    show_command "$CMD"
}


show_vm_hardware() {
    instance_list=$(openstack server list --format value --column ID --column Name --column Image --column Flavor)

    echo "Instance Name | Image ID | CPU Arch | Disk Bus | SCSI Model | OS Distro | OS Version | RAM | Disk | VCPUs"
    echo "---------------------------------------------------------------------------------------------------------"

    while IFS=" " read -r instance_id instance_name image_id instance_flavor; do
        if [[ "$image_id" != "" && $instance_flavor != "" ]]; then
            image_properties=$(openstack image show "$image_id" -f json | jq -r '.properties | "\(.cpu_arch) \(.hw_disk_bus) \(.hw_scsi_model) \(.os_distro) \(.os_version)"')

            cpu_arch=$(echo "$image_properties" | awk '{print $1}')
            hw_disk_bus=$(echo "$image_properties" | awk '{print $2}')
            hw_scsi_model=$(echo "$image_properties" | awk '{print $3}')
            os_distro=$(echo "$image_properties" | awk '{print $4}')
            os_version=$(echo "$image_properties" | awk '{print $5}')

            flavor_properties=$(openstack flavor show "$instance_flavor" -f json | jq -r '"\(.ram) \(.disk) \(.vcpus)"')

            flavor_ram=$(echo "$flavor_properties" | awk '{print $1}')
            flavor_disk=$(echo "$flavor_properties" | awk '{print $2}')
            flavor_vcpus=$(echo "$flavor_properties" | awk '{print $3}')

            echo "$instance_name | $image_id | $cpu_arch | $hw_disk_bus | $hw_scsi_model | $os_distro | $os_version | $flavor_ram | $flavor_disk | $flavor_vcpus"
        else
            echo "$instance_name | No Image | N/A | N/A | N/A | N/A | N/A | N/A | N/A | N/A"
        fi
    done <<< "$instance_list"
}


# Display the menu and handle choices
while true; do
    clear

    echo "❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀"
    echo "❀ The Open Stack Personal Automation and Launch Suite ❀"
    echo "❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀"
    echo "1. Show Info on Project"
    echo "2. Show Projects I'm A Member Of"
    echo "3. Show All Instances"
    echo "4. Show floating IPs"
    echo "5. Show networks"
    echo "6. Show public networks"
    echo "7. Show Bare Metal"
    echo "8. Show All Images"
    echo "9. Show All Flavors"
    echo "a. Show Shares"
    echo "b. Show Quotas"
    echo "c. Run Your Command"
    echo "s. Open OpenStack Shell"
    echo "o. Show Current OpenStack Services"
    echo "q. Exit"
    echo "------------------------------------"

    read -p "Enter your choice [1-9]: " choice

    case $choice in
        1)
            echo "Show info on project $PROJECT_ID:"
            banner "openstack project show \"$PROJECT_ID\""
            openstack project show "$PROJECT_ID"
            ;;

        2)
            echo "Show all projects I'm a member of"
            show_command "openstack project list"
            ;;

        3)
            echo "List servers in project $PROJECT_ID:"
            show_command "openstack server list -f table -c ID -c Name -c Image -c Flavor -c Status"
            ;;

        4)
            echo "Show floating IPs"

