#!/bin/bash

set -e

# Update the system
sudo yum upgrade -y

# Install git if not installed
if ! command -v git &> /dev/null; then
    sudo yum install git -y
fi

# Clone the repository using the Git token
if [ ! -d "/home/ec2-user/drilldevops_startup_scripts" ]; then
    sudo git clone https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/kalyanreddyc/drilldevops_startup_scripts.git /home/ec2-user/drilldevops_startup_scripts
fi

# Navigate to the scripts directory
cd /home/ec2-user/drilldevops_startup_scripts/bash_scripts/

# Make scripts executable
sudo chmod +x *

# Run the Nexus startup script
sudo bash nexus_startup_script.sh

# Wait for Nexus to start
sleep 120s

# Display the Nexus admin password and store it in a temporary file
sudo cat /opt/nexus/sonatype-work/nexus3/admin.password > /tmp/nexus_admin_password.txt
sudo chmod 644 /tmp/nexus_admin_password.txt