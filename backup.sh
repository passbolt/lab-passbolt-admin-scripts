#! /bin/bash

config_file="/etc/passbolt/passbolt.php"

# Set this to the location you'd like backups placed, be sure to leave off the trailing /
backup_dir="/tmp"
# If you want to change how the date is displayed edit this line and then the two lines dealing with mysqldump
backup_dir_date=$backup_dir/backup-$(date +"%Y-%m-%d--%H-%M-%S")

mkdir $backup_dir_date

# This checks if a database environment variable exists and if so uses those as the variables for later
if [ -v DATASOURCES_DEFAULT_HOST ]
then
  db_host=$DATASOURCES_DEFAULT_HOST
  db_port=$DATASOURCES_DEFAULT_PORT
  db_user=$DATASOURCES_DEFAULT_USERNAME
  db_pass=$DATASOURCES_DEFAULT_PASSWORD
  db_database=$DATASOURCES_DEFAULT_DATABASE
  values_set=1
# If environment variables aren't present it checks for the config file and uses those as the variables for later
elif [ -f "$config_file" ]
then
  db_host=$(grep Datasources -A 7 /etc/passbolt/passbolt.php | grep host | sed 's/,*$//' | sed "s/'//g" | sed 's/^[^>]*>//' | awk '{$1=$1};1')
  db_port=$(grep Datasources -A 7 /etc/passbolt/passbolt.php | grep port | sed 's/,*$//' | sed "s/'//g" | sed 's/^[^>]*>//' | awk '{$1=$1};1')
  db_user=$(grep Datasources -A 7 /etc/passbolt/passbolt.php | grep username | sed 's/,*$//' | sed "s/'//g" | sed 's/^[^>]*>//' | awk '{$1=$1};1')
  db_pass=$(grep Datasources -A 7 /etc/passbolt/passbolt.php | grep password | sed 's/,*$//' | sed "s/'//g" | sed 's/^[^>]*>//' | awk '{$1=$1};1')
  db_database=$(grep Datasources -A 7 /etc/passbolt/passbolt.php | grep database | sed 's/,*$//' | sed "s/'//g" | sed 's/^[^>]*>//' | awk '{$1=$1};1') 
  values_set=1
else
  values_set=0
fi

if [ $values_set = 1 ]
then
# If a port isn't specified in the file or env var it will show as a blank and this works around it
  if [ $db_port=="" ]
  then  
    echo "Taking database backup and storing in $backup_dir_date"
    mysqldump -u $db_user --password=$db_pass --host $db_host --no-tablespaces  $db_database > $backup_dir_date/database-$(date +"%Y-%m-%d--%H-%M-%S").sql
  else
    echo "Taking database backup and storing in $backup_dir_date"
    mysqldump -u $db_user --password=$db_pass --host $db_host --port $db_port --no-tablespaces  $db_database > $backup_dir_date/database-$(date +"%Y-%m-%d--%H-%M-%S").sql
  fi
  echo "Copying /etc/passbolt/gpg/serverkey_private.asc to $backup_dir_date"
  cp /etc/passbolt/gpg/serverkey_private.asc $backup_dir_date/.
  echo "Copying /etc/passbolt/gpg/serverkey.asc to $backup_dir_date"
  cp /etc/passbolt/gpg/serverkey.asc $backup_dir_date/.
  echo "Creating archive of $backup_dir_date"
  tar -czvf $backup_dir_date.tar.gz -C $backup_dir_date .
  echo "Cleaning up $backup_dir"
  rm  $backup_dir_date/*
  rmdir $backup_dir_date
else
  echo "Can't determine your values, no backup taken"
fi