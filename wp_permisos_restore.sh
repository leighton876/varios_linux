#!/bin/bash
#######################################################################
# Con crontab -e podemos agregar el script para que se ejecute 
# todas las noches a las 21:50, agregando al final del todo:
# 50 21  * * * /usr/local/bin/wordpress_update 
#######################################################################
# Copyright (c) 2015 Jorge Hernandez - Melendez
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#######################################################################

clear
serveruser="www-data"
wpfile="wp-config.php"
pathold=$(pwd)
pathwww="/var/www"
v_date=$(date +%F | sed "s/-/_/g")
v_hour=$(date +%T | sed "s/:/_/g")
separator="_"
blist=() # <- lista negra vacia de momento para llenarla es asi: blist=( sitio1 sitio2 )
blisted="False"

echo "Procediendo a aplicar los permisos y propietarios correspondientes a todos los wordpress..."
for site in $(ls $pathwww); do
    pathnow="$pathwww/$site"
    echo -e "\nEntrando en $pathnow"
    cd $pathnow
    # si esta blaclisted entonces activo blisted:
    if [[ "$(echo ${blist[@]} | grep -ic $site)" > "0" ]];then
        echo "$site is blacklisted!, will not be updated"
        blisted="True"
    fi
    # entramos y lo hacemos si no esta blacklisted:
    if [ -f "$wpfile" ] && [ "$blisted" != "True" ]; then
        # PROPIETARIOS:
        echo "Haciendo chown $serveruser:$serveruser -R $pathnow"
        chown $serveruser:$serveruser -R $pathnow
        echo "Haciendo chown root:root $pathnow"
        chown root:root $pathnow
        # excepcion para enjaular el vsftp de wgm:
        if [ $site == "wgm" ]; then
            echo "Haciendo chown admin_worldgam:ftp -R $pathnow/media/digital_magazine para el ftp de wgm"
            chown admin_worldgam:ftp -R $pathnow/media/digital_magazine
        fi
        # PERMISOS:
        echo "Haciendo find . -type d -exec chmod 755 {} \; # para los directorios: rwxr-xr-x"
        find . -type d -exec chmod 755 {} \; # Change directory permissions rwxr-xr-x
        echo "Haciendo find . -type f -exec chmod 644 {} \;  # para los archivos: rw-r--r--"
        find . -type f -exec chmod 644 {} \;  # Change file permissions rw-r--r--
        echo "Haciendo chmod 775 $pathnow/wp-content para tener el wp-content con 775 para los core updates."
        chmod 775 $pathnow/wp-content
        # Comprobando si tienen o no el direct para los core update correctos:
        if [ "$(grep -ic 'direct' $pathnow/$wpfile)" == "1" ]; then
            echo "No tiene define('FS_METHOD','direct'); en el $wpfile, se lo agrego."
            echo " " >> $pathnow/$wpfile
            echo "define('FS_METHOD','direct');" >> $pathnow/$wpfile
        fi
    else
        echo "$pathnow no es un wordpress"
    fi
    blisted="False"
done

echo ""
echo "Fin del script."
cd $pathold
