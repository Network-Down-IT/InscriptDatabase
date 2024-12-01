#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Generate a random password
DB_PASSWORD=$(openssl rand -base64 16)
echo "Generated Database Password: $DB_PASSWORD"

# PostgreSQL installation
echo "Installing PostgreSQL..."
sudo apt update
sudo apt install -y postgresql postgresql-contrib

# Configure PostgreSQL
echo "Configuring PostgreSQL..."
if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='inscript'" | grep -q 1; then
  echo "Role 'inscript' already exists. Skipping creation."
else
  sudo -u postgres psql -c "CREATE USER inscript WITH PASSWORD '$DB_PASSWORD';"
fi

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

# Update pg_hba.conf for external connections
echo "Updating pg_hba.conf to allow external connections..."
PG_HBA_PATH="/etc/postgresql/16/main/pg_hba.conf"
sudo bash -c "echo 'host    all             all             0.0.0.0/0               scram-sha-256' >> $PG_HBA_PATH"

# Update postgresql.conf to listen on all addresses
echo "Updating postgresql.conf to allow PostgreSQL to listen on all IP addresses..."
PG_CONF_PATH="/etc/postgresql/16/main/postgresql.conf"
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" $PG_CONF_PATH

# Restart PostgreSQL to apply changes
echo "Restarting PostgreSQL..."
sudo systemctl restart postgresql

# Install pgAdmin4
echo "Installing pgAdmin4..."
echo "Adding pgAdmin4 repository..."
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
sudo apt install -y pgadmin4-web

# Configure the webserver for pgAdmin4
echo "Configuring pgAdmin4 web mode..."
sudo /usr/pgadmin4/bin/setup-web.sh

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
pgAdmin4 URL: http://localhost/pgadmin4
PostgreSQL is configured to listen on all IP addresses.
"
