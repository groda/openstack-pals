# OpenStack Personal Automation and Launch Suite

## Description

This project provides a shell script with a menu-driven interface to support common tasks using the OpenStack command-line API client. It aims to simplify and automate frequent OpenStack operations, while also serving as a learning tool to deepen understanding of OpenStack and command-line scripting.

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

### Run in Docker

To run in a docker container:

5. Build an image
   ```bash
   docker build -t openstack-pals .

6. Run in container
   ```bash
   docker run -ti --rm -v ~/.pals:/root/.pals -v ~/.openstack:/root/.openstack openstack-pals

7. Optionally, create an alias
   ```
   alias openstack-pals="docker run -ti --rm -v ~/.pals:/root/.pals -v ~/.openstack:/root/.openstack openstack-pals"
