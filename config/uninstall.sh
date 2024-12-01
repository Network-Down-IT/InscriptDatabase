#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "Uninstalling PostgreSQL, pgAdmin4, and removing InscriptDatabase directory..."

# Stop PostgreSQL service
echo "Stopping PostgreSQL service..."
sudo systemctl stop postgresql || echo "PostgreSQL service is not running."

# Remove PostgreSQL and its related packages
echo "Removing PostgreSQL packages..."
sudo apt-get --purge remove -y postgresql* libpq* postgresql-client* postgresql-common* postgresql-contrib*
sudo apt-get autoremove -y
sudo apt-get autoclean

# Remove PostgreSQL directories
echo "Removing PostgreSQL directories..."
sudo rm -rf /etc/postgresql
sudo rm -rf /var/lib/postgresql
sudo rm -rf /var/log/postgresql

# Remove PostgreSQL user and group
echo "Removing PostgreSQL user and group..."
sudo deluser postgres || echo "PostgreSQL user does not exist."
sudo delgroup postgres || echo "PostgreSQL group does not exist."

# Remove pgAdmin4 packages
echo "Removing pgAdmin4 packages..."
sudo apt-get --purge remove -y pgadmin4*
sudo apt-get autoremove -y
sudo apt-get autoclean

# Remove pgAdmin4 directories
echo "Removing pgAdmin4 directories..."
sudo rm -rf ~/.pgadmin4
sudo rm -rf /var/lib/pgadmin
sudo rm -rf /var/log/pgadmin
sudo rm -rf /etc/pgadmin4

# Remove pgAdmin4 repository configuration
echo "Removing pgAdmin4 repository..."
sudo rm -f /etc/apt/sources.list.d/pgadmin4.list
sudo rm -f /usr/share/keyrings/packages-pgadmin-org.gpg

# Check for any remaining processes
echo "Checking for remaining PostgreSQL or pgAdmin4 processes..."
pg_processes=$(ps aux | grep -E 'postgres|pgadmin' | grep -v grep)

if [ -n "$pg_processes" ]; then
  echo "Found running processes. Killing them..."
  echo "$pg_processes" | awk '{print $2}' | xargs sudo kill -9 || echo "No processes found to kill."
else
  echo "No remaining PostgreSQL or pgAdmin4 processes found."
fi

# Remove InscriptDatabase directory
echo "Removing InscriptDatabase directory..."
cd ~ || echo "Failed to navigate to home directory."
if [ -d "InscriptDatabase" ]; then
  sudo rm -rf InscriptDatabase
  echo "InscriptDatabase directory has been removed."
else
  echo "InscriptDatabase directory does not exist."
fi

# Confirm uninstallation
echo "
Uninstallation Complete!
-------------------------
PostgreSQL, pgAdmin4, and the InscriptDatabase directory have been uninstalled and removed.
You can now reinstall and start from scratch.
"
