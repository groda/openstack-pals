FROM python:3.12-alpine

# Install bash, build dependencies, and other necessary tools
RUN apk add --no-cache bash gcc musl-dev python3-dev linux-headers

# Copy your requirements.txt file to the container
COPY requirements.txt /app/requirements.txt

# Install dependencies from requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy your script or application files
COPY ./openstack-pals.sh /app

WORKDIR /app

# Command to execute your script
CMD ["./openstack-pals.sh"]
