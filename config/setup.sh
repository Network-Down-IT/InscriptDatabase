#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Generate a random password
DB_PASSWORD=$(openssl rand -base64 16)
echo "Generated Database Password: $DB_PASSWORD"

# PostgreSQL installation
echo "Installing PostgreSQL..."
sudo apt update
sudo apt install -y postgresql postgresql-contrib

# Check if the role already exists
echo "Configuring PostgreSQL..."
if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='inscript'" | grep -q 1; then
  echo "Role 'inscript' already exists. Skipping creation."
else
  sudo -u postgres psql -c "CREATE USER inscript WITH PASSWORD '$DB_PASSWORD';"
fi

# Check if the database already exists
if sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='inscript_db'" | grep -q 1; then
  echo "Database 'inscript_db' already exists. Skipping creation."
else
  sudo -u postgres psql -c "CREATE DATABASE inscript_db;"
  sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE inscript_db TO inscript;"
fi

# Set up schemas
echo "Setting up schemas..."
sudo -u postgres psql -d inscript_db <<EOF
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'core') THEN
    CREATE SCHEMA core;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'content') THEN
    CREATE SCHEMA content;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'auth') THEN
    CREATE SCHEMA auth;
  END IF;
END
\$\$;
EOF

echo "Schemas 'core', 'content', and 'auth' created or verified."

# Install pgAdmin4
echo "Installing pgAdmin4..."
echo "Adding pgAdmin4 repository..."
curl -k https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/pgadmin-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/pgadmin-archive-keyring.gpg] http://ftp.pgadmin.org/pgadmin4/apt/ubuntu $(lsb_release -cs) pgadmin4 main" | sudo tee /etc/apt/sources.list.d/pgadmin4.list
sudo apt update
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
