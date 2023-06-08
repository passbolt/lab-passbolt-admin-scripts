#! /bin/bash

if ! command -v mysqldump  &> /dev/null
then
    echo "+------------------------------------------------------------------------------------------+"
    echo "|                         mysqldump is required to run this script                         |"
    echo "|           Try installing either mysql-server or mariadb-server to correct this           |"
    echo "+------------------------------------------------------------------------------------------+"
    exit
fi
# Set this to the location you'd like backups placed, be sure to leave off the trailing /
backup_dir="/tmp"
# If you want to change how the date is displayed edit this line
backup_dir_date=$backup_dir/backup-$(date +"%Y-%m-%d--%H-%M-%S")
backup_file=$backup_dir/backup-$(date +"%Y-%m-%d--%H-%M-%S").tar.gz

if [ -f /.dockerenv ]
then
  echo "+------------------------------------------------------------------------------------------+"
  echo "Docker detected"
  echo "+------------------------------------------------------------------------------------------+"
  su -s /bin/bash -c "mkdir $backup_dir_date" www-data 
  echo "Taking database backup and storing in $backup_dir_date"

  su -s /bin/bash -c "./bin/cake passbolt mysql_export --dir $backup_dir_date" www-data
  echo "+------------------------------------------------------------------------------------------+"
  echo "Copying /etc/environment to $backup_dir_date"
  echo "+------------------------------------------------------------------------------------------+"
  cp /etc/environment $backup_dir_date/.
else
  echo "+------------------------------------------------------------------------------------------+"
  echo "Docker not detected"
  echo "+------------------------------------------------------------------------------------------+"
  mkdir $backup_dir_date
  echo "Taking database backup and storing in $backup_dir_date"
  echo "+------------------------------------------------------------------------------------------+"
  ./usr/share/php/passbolt/bin/cake passbolt mysql_export --dir $backup_dir_date
  echo "+------------------------------------------------------------------------------------------+"
  echo "Copying /etc/passbolt/passbolt.php to $backup_dir_date"
  echo "+------------------------------------------------------------------------------------------+"
  cp /etc/passbolt/passbolt.php $backup_dir_date/.
fi
echo "Copying /etc/passbolt/gpg/serverkey_private.asc to $backup_dir_date"
echo "+------------------------------------------------------------------------------------------+"
cp /etc/passbolt/gpg/serverkey_private.asc $backup_dir_date/.
echo "Copying /etc/passbolt/gpg/serverkey.asc to $backup_dir_date"
echo "+------------------------------------------------------------------------------------------+"
cp /etc/passbolt/gpg/serverkey.asc $backup_dir_date/.
echo "Creating archive of $backup_dir_date"
echo "+------------------------------------------------------------------------------------------+"
tar -czvf $backup_dir_date.tar.gz -C $backup_dir_date .
echo "Cleaning up $backup_dir"
echo "+------------------------------------------------------------------------------------------+"
rm  $backup_dir_date/*
rmdir $backup_dir_date
echo "Backup completed you can find the file as $backup_file"
echo "+------------------------------------------------------------------------------------------+"
