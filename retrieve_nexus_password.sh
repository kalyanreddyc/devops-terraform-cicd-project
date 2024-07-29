# retrieve_nexus_password.sh
#!/bin/bash

# Check if the nexus_admin_password.txt file exists
if [ -f "nexus_admin_password.txt" ]; then
  echo -e "\nNexus admin password:"
  cat nexus_admin_password.txt
  echo -e "\n"
else
  echo "The nexus_admin_password.txt file does not exist. Please check the Terraform output and the provisioning steps."
fi