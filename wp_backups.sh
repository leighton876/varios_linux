#!/bin/bash
#####################################################################################
# Based in http://www.juliojosesanz.com/script-bash-para-hacer-backup-de-wordpress/ 
# Modified by zebus 
#####################################################################################
# For security i recommend:
# chown root:root wp_backups.sh
# chmod 700 wp_backups.sh
#####################################################################################
'''
Copyright (c) 2015 Jorge Hernandez - Melendez
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
'''

# Chek Root User:
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
     exit -1
fi

# Chek if is already running:
chekrun="/tmp/scriptbackupisrun.txt"
if [ -f $chekrun ]; then
    echo "the backup is already running!"
    exit -1
else
        clear
	touch $chekrun
	# Date variable for everyday. It will have the format 20150507 -> year 2015, month 05, day 07
	v_date=$(date +%F | sed "s/-/_/g")
        v_hour=$(date +%T | sed "s/:/_/g")
        separator="_"
        tipo=$(echo "$1" | sed "s/-//g")
	# Wordpress database user
	wpdb_user="your_db_user_name"
	# Wordpress database password
	wpdb_pass="your_db_password"
	# Wordpress database name
	wpdb_dbname="your_db_name"
	# Email to send a notification when a backup is done
	wp_email="your_mail@mail.any"
	# Wordpress installation location (without final slash!) e.g.:/var/www/sites/mysite.com
	wp_documentroot="your_root_path_site"
	# Wordpress backup destination directory e.g.: /usr/local/backups/wordpress (without final slash!)
	wp_backup_dir="your_path_folderbackups"
        
        echo "backup to path: $wp_backup_dir" 	
        echo "Year Month Day Hour type:"
	
        function create_dirs {
	    # Create backup directories
	    mkdir -p $wp_backup_dir/$v_date$separator$v_hour$separator$tipo/files
	    mkdir -p $wp_backup_dir/$v_date$separator$v_hour$separator$tipo/database
	}
	
	function tar_delete_and_mail {
	    # Create TAR file and compress with GZIP
	    cd $wp_backup_dir
	    tar -zcvf $v_date$separator$v_hour$separator$tipo.tar.gz $v_date$separator$v_hour$separator$tipo/ --remove-files
	    # Delete old backups created mtime days ago (91 osea 3 meses aprox by default)
	    find $wp_backup_dir -maxdepth 1 -mtime +91 -exec rm -rf "{}" ";" > /dev/null
	    # Send mail to confirm that everything has gone as expected
	    echo 'Backup for your site has been completed' | mail -s "Wordpress backup successfully completed" $wp_email
            rm -f $chekrun
            echo "Existents backups:"
            ls -al --color=auto $wp_backup_dir
	}
	
	# acciones en funcion de los argumentos:
	if [ "$1" == "-db" ]; then
	    create_dirs
	    # backup solo de la db:
	    # Backup files and MySQL Wordpress Database
	    mysqldump -u$wpdb_user -p$wpdb_pass -h localhost $wpdb_dbname > $wp_backup_dir/$v_date$separator$v_hour$separator$tipo/database/wpdatabase.sql
	    tar_delete_and_mail
	
	elif [ "$1" == "-files" ]; then
	    create_dirs
	    # backup solo de los archivos:
	    cp -R $wp_documentroot/* $wp_backup_dir/$v_date$separator$v_hour$separator$tipo/files/
	    tar_delete_and_mail
	
	elif [ "$1" == "-all" ]; then
	    create_dirs
	    # backup de todo:
	    # Backup files and MySQL Wordpress Database
	    cp -R $wp_documentroot/* $wp_backup_dir/$v_date$separator$v_hour$separator$tipo/files/
	    mysqldump -u$wpdb_user -p$wpdb_pass -h localhost $wpdb_dbname > $wp_backup_dir/$v_date$separator$v_hour$separator$tipo/database/wpdatabase.sql
	    tar_delete_and_mail
	    
	else
            rm -f $chekrun 2>/dev/null
	    clear
	    echo "This script needs arguments."
	    echo "Arguments available:"
	    echo "-db"
	    echo "-files"
	    echo "-all"
	    exit -1
	fi
fi
