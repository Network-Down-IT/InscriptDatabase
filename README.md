# InscriptDatabase

**InscriptDatabase** is the local database configuration for the Inscript note-taking application. It includes PostgreSQL setup, schemas, and optional pgAdmin4 for database management.

## Features
100% Local Database: Designed to work on Linux Ubuntu with PostgreSQL. 
Preconfigured Schemas: Includes `core`, `content`, and `auth` schemas. Random Password Generation: 
Securely generates a random password for the database user. Integrated pgAdmin4: Optional web-based GUI for managing the database.

## Requirements
Linux Ubuntu Operating System
Bash (for running the setup script)
Internet access (for installing PostgreSQL and pgAdmin4).

## Quick Start
Clone the repository to your local machine by running:
`git clone https://github.com/Network-Down-IT/InscriptDatabase.git && cd InscriptDatabase && chmod +x setup.sh && ./setup.sh`. 

After running the setup script, the following details will be displayed:
Database Name: `inscript_db`
Username: `inscript`
Password: *(randomly generated, displayed during setup)*
Schemas: `core`, `content`, `auth`
pgAdmin4 Email: `inscript@inscript.io`
pgAdmin4 Password: `!nscriptD@tabas3`

To connect to the database: 
Host: `localhost`
Port: `5432`
Database: `inscript_db`
Username: `inscript`
Password: *(use the randomly generated password)*

To access pgAdmin4: 
Open your browser and navigate to `http://localhost/pgadmin4`
Log in with Email: `inscript@inscript.io`
Password: `!nscriptD@tabas3`

## Database Schemas
Core Schema: Used for system-level configurations.
Content Schema: Stores documents and user-generated content.
Auth Schema: Manages users and authentication.

## Troubleshooting
If PostgreSQL or pgAdmin4 fails to install, ensure your system is up-to-date:
`sudo apt update && sudo apt upgrade -y`
Verify PostgreSQL is running:
`sudo systemctl status postgresql`
Check pgAdmin4 installation: `pgadmin4 --version`

## License
This repository is licensed under the MIT License.
