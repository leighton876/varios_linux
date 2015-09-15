#!/bin/bash
#######################################################################
# Necesitas tener instalado wp-cli http://wp-cli.org/.
# Con crontab -e podemos agregar el script para que se ejecute 
# todas las noches a las 10pm, agregando al final del todo:
# 00 22  * * * /usr/local/bin/wordpress_update 
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
normaluser="YourUser"
wpfile="wp-config.php"
pathold=$(pwd)
pathwww="/var/www"
v_date=$(date +%F | sed "s/-/_/g")
v_hour=$(date +%T | sed "s/:/_/g")
separator="_"
adminmail1="tumail@mail.com"
adminmail2="tumail@mail.com"
frommail="admin@server.com"
blist=() # <- lista negra vacia de momento para llenarla es asi:
#blist=( nombre1 nombre2 )
#echo ${blist[@]}
blisted="False"
# borrando logs anteriores
#rm /tmp/wp_update_all*.log 2>/dev/null

echo "Buscando actualizaciones..."
for site in $(ls $pathwww); do
    pathnow="$pathwww/$site"
    cd $pathnow
    # si esta blaclisted entonces activo blisted:
    if [[ "$(echo ${blist[@]} | grep -ic $site)" > "0" ]];then
        echo "$site is blacklisted!, will not be updated"
        blisted="True"
    fi
    # entramos y lo hacemos si no esta blacklisted:
    if [ -f "$wpfile" ] && [ "$blisted" != "True" ]; then
        pathlog="/tmp/wp_update_all_$v_date$separator$v_hour$separator$site.log"
        chkandup=$(sudo -u "$normaluser" -i wp plugin update --all --path="$pathnow" | tee "$pathlog" | wc -l)
        readlog=$(cat $pathlog)
        if [ "$chkandup" != "1" ]; then
            echo "$pathnow Actualizado!"
            # Usage: mail -eiIUdEFntBDNHRV~ -T FILE -u USER -h hops -r address -s SUBJECT -a FILE -q FILE -f FILE -A ACCOUNT -b USERS -c USERS -S OPTION users
            echo -e "WP-CLI: $pathnow executed! \n Report:\n\n $readlog." | mail -r $frommail -s "Wordpress $pathnow Actualizado" -c "$adminmail1 $adminmail2"
        else # el log solo se guarda si se hizo actualizacion:
            rm $pathlog 2>/dev/null
        fi
    fi
    blisted="False"
done

# Delete residuals:
rm /home/$normaluser/.wp-cli/cache/plugin/*.zip 2>/dev/null

echo "Fin del script."
cd $pathold
