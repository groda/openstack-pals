# OpenStack Personal Automation and Launch Suite

## Description

This project provides a shell script with a menu-driven interface to simplify common OpenStack operations—such as displaying project details, listing images, and managing flavors—through the OpenStack command-line client. It streamlines frequent administrative tasks while serving as a practical tool for learning OpenStack concepts and command-line scripting.

```
❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀
❀ The Open Stack Personal Automation and Launch Suite ❀
❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀
1. Show Info on Project
2. Show Info on User
3. Show Projects I'm A Member Of
4. Show All Instances
5. Show floating IPs
6. Show networks
7. Show Bare Metal
8. Show All Images
9. Show All Flavors
a. Show Shares
b. Show Quotas
c. Show Current OpenStack Services
x. Run Your Command
y. Open OpenStack Shell
q. Exit
------------------------------------
Enter your choice [1-9]: 
```

The idea for this project came from my desire to create a shell tool to learn specific shell commands—essentially a self-evolving, learning-based personalized interactive tutorial command (in this case, I wanted to explore the `openstack` CLI command). Although I haven’t implemented that tool yet, this script emerged during the process. Another source of inspiration was the vintage IBM AIX interface for system administration, which I greatly appreciated back in the day.

> [!NOTE]
> Important Notice:
> This application mainly operates in **read-only mode**. It is designed as an OpenStack client for inspecting and interacting with your OpenStack environment without making any modifications to your infrastructure.
> 
> The only way to modify your OpenStack infrastructure through this app is by opening an OpenStack shell through the "Open OpenStack Shell" menu item and typing your commands.

## Installation

To clone this repository and set up the project locally, follow these steps:

### Prerequisites

- **uv** (required) - Fast Python package manager  
  Install with:
   ```bash
   # macOS / Linux
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```
   Note: Restart your terminal or run source $HOME/.cargo/env` to finalize the installation.

- **yq**
   ```bash
    brew install yq          # macOS
    # or
    sudo apt install yq      # Linux
    ```

- **bash 4***
   The `mapfile` command is only available starting from `bash` version 4. Since on macOS has by defult `bash 3`,
   you might need to instal it with
   ```bash
    export HOMEBREW_NO_AUTO_UPDATE=1 # preventing brew from auto-upgrading
    brew install bash         
    ```
    (this will install the latest version of `bash`)

### Download

1. Clone the repository:
   ```bash
   git clone https://github.com/groda/openstack-pals.git

2. Navigate into the project directory:
   ```bash
   cd openstack-pals

### Credentials File  

The script requires a **credentials file** for establishing a connection with your OpenStack projecty, by default   
```bash
./clouds.yaml
```

The repository includes a sample credentials file `sample_clouds.yaml` with credentials for two different clouds as a reference.

If your credentials file is stored elsewhere, the script will prompt you to provide its location during the **initial interactive setup**.  

### Run

Run with
   ```bash
   ./openstack-pals.sh
   ```

### Show an usage message

   ```bash
   ./openstack-pals.sh -h
   ```


## Run in Docker

To run in a docker container:

5. Build an image
   ```bash
   docker build -t openstack-pals .

6. Run in container
   ```bash
   docker run -ti --rm -v ~/.pals:/root/.pals -v ~/.openstack:/root/.openstack openstack-pals

   **Note:** this assumes that your credentials file is saved under ~/.openstack/app-cred-<YOUR_PROJECT>-openrc.sh 
   (inside the container /root/.openstack/app-cred-<YOUR_PROJECT>-openrc.sh)

7. Optionally, create an alias
   ```bash
   alias openstack-pals="docker run -ti --rm -v ~/.pals:/root/.pals -v ~/.openstack:/root/.openstack openstack-pals"
   ```
   
   and run with:
   ```bash
   openstack-pals
