# OpenStack Personal Automation and Launch Suite

## Description

This project provides a shell script with a menu-driven interface to simplify common OpenStack operations—such as displaying project details, listing images, and managing flavors—through the OpenStack command-line client. It streamlines frequent administrative tasks while serving as a practical tool for learning OpenStack concepts and command-line scripting.

```
❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀
❀ The Open Stack Personal Automation and Launch Suite ❀
❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀~❀
1. Show Info on Project
2. Show Projects I'm A Member Of
3. Show All Instances
4. Show floating IPs
5. Show networks
6. Show public networks
7. Show Bare Metal
8. Show All Images
9. Show All Flavors
a. Show Shares
b. Show Quotas
c. Run Your Command
s. Open OpenStack Shell
o. Show Current OpenStack Services
q. Exit
------------------------------------
Enter your choice: 
```

The idea for this project came from my desire to create a shell tool to learn specific shell commands—essentially a self-evolving, learning-based personalized interactive tutorial command (in this case, I wanted to explore the `openstack` CLI command). Although I haven’t implemented that tool yet, this script emerged during the process. Another source of inspiration was the vintage IBM AIX interface for system administration, which I greatly appreciated back in the day.

## Quick start

### Option A — Docker (easiest, zero host dependencies)

```bash
git clone https://github.com/groda/openstack-pals.git
cd openstack-pals
# place your clouds.yaml in this directory
docker build -t openstack-pals .
docker run -ti --rm -v .:/app openstack-pals
```

Optional alias:

```bash
alias openstack-pals='docker run -ti --rm -v .:/app openstack-pals'
```

### Option B — Local install (one command)

```bash
curl -fsSL https://raw.githubusercontent.com/groda/openstack-pals/main/install.sh | bash
cd openstack-pals
./openstack-pals.sh
```

The installer puts `uv`, `yq`, and `fzf` into `~/.local/bin` if they are missing.  
You still need a `clouds.yaml` file (see `sample_clouds.yaml`).

On macOS you may also need a newer Bash:

```bash
brew install bash
/opt/homebrew/bin/bash openstack-pals.sh
```

### Option C — Manual

1. Install prerequisites if missing: `uv`, `yq`, `fzf`, and Bash ≥ 4.
2. Clone the repo and run `./openstack-pals.sh`.

The script will automatically create a virtual environment and install the OpenStack clients.

## Credentials

The script requires a **clouds.yaml** file. By default it looks for `./clouds.yaml`.

A sample file (`sample_clouds.yaml`) is included. You can also use the standard location `~/.config/openstack/clouds.yaml`.

If the file is elsewhere, the script will prompt you for the path on first run.

## Run

```bash
./openstack-pals.sh
```

Show usage:

```bash
./openstack-pals.sh -h
```

## About

The Open Stack Personal Automation and Launch Suite
