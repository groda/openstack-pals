FROM python:3.12-alpine

# Install runtime dependencies
# - bash ≥ 4 (mapfile)
# - yq, fzf (required by the script)
# - curl (optional, only used if the script tries to self-install tools)
# - build deps in case pip needs to compile anything
RUN apk add --no-cache \
    bash \
    curl \
    yq \
    fzf \
    gcc \
    musl-dev \
    python3-dev \
    linux-headers \
    jq

# Copy requirements and install OpenStack clients system-wide
# (the script will still create its own venv, but this keeps the image usable)
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy the script
COPY openstack-pals.sh /app/openstack-pals.sh
RUN chmod +x /app/openstack-pals.sh

WORKDIR /app

CMD ["./openstack-pals.sh"]
