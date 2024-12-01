#!/bin/bash

# Generate a random password
DB_PASSWORD=$(openssl rand -base64 16)
echo "Generated Database Password: $DB_PASSWORD"

# PostgreSQL installation
echo "Installing PostgreSQL..."
sudo apt update
sudo apt install -y postgresql postgresql-contrib

# Configure PostgreSQL
sudo -u postgres psql <<EOF
CREATE USER inscript WITH PASSWORD '$DB_PASSWORD';
CREATE DATABASE inscript_db;
GRANT ALL PRIVILEGES ON DATABASE inscript_db TO inscript;
EOF

echo "Database 'inscript_db' created with user 'inscript'."

# Set up schemas
echo "Setting up schemas..."
sudo -u postgres psql -d inscript_db <<EOF
CREATE SCHEMA core;
CREATE SCHEMA content;
CREATE SCHEMA auth;
EOF

echo "Schemas 'core', 'content', and 'auth' created."

# Install pgAdmin4
echo "Installing pgAdmin4..."
sudo apt install -y pgadmin4

# Set up pgAdmin4 user
PGADMIN_EMAIL="inscript@inscript.io"
PGADMIN_PASSWORD="!nscriptD@tabas3"

# Create the pgAdmin4 configuration directory if it doesn't exist
mkdir -p ~/.pgadmin4/
echo "
{
  \"Servers\": {
    \"1\": {
      \"Name\": \"InscriptDatabase\",
      \"Group\": \"Servers\",
      \"Port\": 5432,
      \"Username\": \"inscript\",
      \"Password\": \"$DB_PASSWORD\"
    }
  }
}
" > ~/.pgadmin4/servers.json

echo "pgAdmin4 installed with user: $PGADMIN_EMAIL and password: $PGADMIN_PASSWORD"

# Display connection info
echo "
Database Setup Complete!
-------------------------
Database Name: inscript_db
Username: inscript
Password: $DB_PASSWORD
Schemas: core, content, auth
pgAdmin4 Email: $PGADMIN_EMAIL
pgAdmin4 Password: $PGADMIN_PASSWORD
"
