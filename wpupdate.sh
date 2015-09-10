#!/bin/bash
##################################
# Necesitas tener instalado wp-cli
##################################
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

clear
wpfile="wp-config.php"
pathold=$(pwd)
pathwww="/var/www"
rm $pathlog 2>/dev/null
v_date=$(date +%F | sed "s/-/_/g")
v_hour=$(date +%T | sed "s/:/_/g")
separator="_"
#adminmail="alejandro@sciremedia.com"
adminmail="jorge@sciremedia.com"
blist=() # <- lista negra vacia de momento para llenarla es asi:
#blist=( epf elpuntofrio )
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
        chkandup=$(sudo -u jorge -i wp plugin update --all --path="$pathnow" | tee "$pathlog" | wc -l)
        readlog=$(cat $pathlog)
        if [ "$chkandup" != "1" ]; then
            echo "$pathnow Actualizado!"
            echo -e "Wordpres: $pathnow UPDATED! \n Report:\n\n $readlog." | mail -s "Wordpress $pathwp Actualizado" $adminmail
        else # el log solo se guarda si se hizo actualizacion:
            rm $pathlog 2>/dev/null
        fi
    fi
    blisted="False"
done

echo "Fin del script."
cd $pathold
