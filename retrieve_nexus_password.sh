# retrieve_nexus_password.sh
#!/bin/bash

# Check if the nexus_admin_password.txt file exists
if [ -f "nexus_admin_password.txt" ]; then
  echo "Nexus admin password:"
  cat nexus_admin_password.txt
  echo
else
  echo "The nexus_admin_password.txt file does not exist. Please check the Terraform output and the provisioning steps."
fi
