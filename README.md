# OpenStack Personal Automation and Launch Suite

## Description

This project provides a shell script with a menu-driven interface to support common tasks using the OpenStack command-line API client. It aims to simplify and automate frequent OpenStack operations, while also serving as a learning tool to deepen understanding of OpenStack and command-line scripting.

The idea for this project came from my desire to create a shell tool to learn specific shell commands—essentially a self-evolving, learning-based personalized interactive tutorial command (in this case, I wanted to explore the `openstack` CLI command). Although I haven’t implemented that tool yet, this script emerged during the process. Another source of inspiration was the vintage IBM AIX interface for system administration, which I greatly appreciated.

> [!NOTE]
> Important Notice:
> This application mainly operates in **read-only mode**. It is designed as an OpenStack client for inspecting and interacting with your OpenStack environment without making any modifications to your infrastructure.
> 
> The only way to modify your OpenStack infrastructure in this app is by opening an OpenStack shell through the "Open OpenStack Shell" menu item and typing your commands.
>
> The **worst-case scenario** is that the application may not function as intended due to misconfigured connections or incorrect settings. In such cases, no changes will be made to your OpenStack environment.

## Installation

To clone this repository and set up the project locally, follow these steps:

1. Clone the repository:
   ```bash
   git clone https://github.com/groda/openstack-pals.git

2. Navigate into the project directory:
   ```bash
   cd openstack-pals

3. Show an usage message
   ```bash
   ./openstack-pals.sh -h

4. Run
   ```bash
   ./openstack-pals.sh


## Configuration Files

The script creates and manages two files in your $HOME directory to store connection parameters (such as username and project name). **These files are automatically managed by the script and do not need to be edited manually**.

- `$HOME/.pals` – The main configuration file containing your connection parameters.  
- `$HOME/.pals.bak` – A backup file that stores the history of previous configurations.

These files **do not contain any passwords**. They are automatically updated by the script during execution.


## Credentials File  

The script requires a **credentials file** for establishing a connection with your OpenStack project. By default, this file should be saved under:  
```bash
$HOME/.openstack/app-cred-<YOUR_PROJECT>-openrc.sh
```

If your credentials file is stored elsewhere, the script will prompt you to provide its location during the **initial interactive setup**.  

> [!NOTE]
> **Note:**
> The credentials file is not automatically created by the script. You must ensure it exists before running the script.  


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
