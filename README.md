# Useful Scripts
This repository is meant to hold various scripts that passbolt users might find useful.

## backup.sh
This script takes a database dump, copies the server GPG keys, and then `tar`s them in a designated location so that it is easier to implement a good backup plan. This backup script requires the ability to run mysqldump on the host you are running it on. This means that for Docker installs you'll need to install mariadb-server. Additionally the user you run this as will need the correct permissions to access the `/etc/passbolt` directory and wherever you select as the backup directory(currently set to `/tmp`).