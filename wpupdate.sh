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
usuarioftpxweb="usuario"
serveruser="www-data"
wpfile="wp-config.php"
pathold=$(pwd)
pathwww="/var/www"
date=$(date +%F | sed "s/-/_/g")
hour=$(date +%T | sed "s/:/_/g")
sep="_"
frommail="wp-cli@yourfakemail.com"
adminmail1="server_admin1@real_account.com"
adminmail2="server_admin2@real_account.com"
blist=() # <- lista negra vacia de momento para llenarla es asi: blist=( sitio1 sitio2 )
#echo ${blist[@]}
blisted="False"

echo "Starting..."
for site in $(ls $pathwww); do
    pathnow="$pathwww/$site"
    cd $pathnow
    # si esta blaclisted entonces activo blisted:
    if [[ "$(echo ${blist[@]} | grep -ic $site)" > "0" ]];then
        echo "$site is blacklisted!, nothing will be done."
        blisted="True"
    fi
    # entramos y lo hacemos si no esta blacklisted:
    if [ -f "$wpfile" ] && [ "$blisted" != "True" ]; then
        pathlog="/tmp/wp_update_$date$sep$hour$sep$site.log"
        echo "wp-cli cheking/runing in: $pathlog"
        #pathlogcore="/tmp/wp_update_$date$sep$hour$sep$site_core.log"
        chown $normaluser:$serveruser -R $pathnow
        wpcli=$(sudo -u "$normaluser" -i wp plugin update --all --path="$pathnow" | sudo tee "$pathlog" | wc -l)
        chown $serveruser:$serveruser -R $pathnow
        chown root:root $pathnow
        # Excepcion para enjaular el vsftp de xweb:
        # el home del usuarioftpxweb tiene que ser /var/www/xweb.es/media/digital_magazin
        # Entonces en el etc password:
        # usuarioftpxweb:x:algo:algo:Usuario de ftp xweb:/var/www/xweb.es/media/digital_magazine/:/bin/ftp
        # donde /bin/ftp es una falsa shell que es un directorio de root:root con rwxr-xr-x
        # tiene que existir el grupo ftp tambien.
        if [ $site == "xweb.es" ]; then
            echo "Haciendo chown usuarioftpxweb:ftp -R $pathnow/media/digital_magazine para el ftp de xweb"
            chown usuarioftpxweb:ftp -R $pathnow/media/digital_magazines
            chown root:root $pathnow/media
        fi
        if [ "$wpcli" != "1" ]; then
            echo "target: $pathnow"
            echo -e "WP-CLI: $pathnow executed! \nReport:\n\n" | cat $pathlog | tee /tmp/mmsg
            cat /tmp/mmsg | mailx -r "$frommail" -s "WP-CLI plugin update for: $pathnow " -c "$adminmail2" $adminmail1
            rm /tmp/mmsg 2>/dev/null
        else # el log solo se guarda si se hizo actualizacion:
            rm $pathlog 2>/dev/null
        fi
        #chkandupcore=$(sudo -u "$normaluser" -i wp core update --path="$pathnow" | tee "$pathlogcore" | wc -l)
    fi
    blisted="False"
done

# Delete residuals:
rm /home/$normaluser/.wp-cli/cache/plugin/*.zip 2>/dev/null
# borrando logs anteriores, ya que hay una copia en el mail...
rm /tmp/wp_update_*.log 2>/dev/null

echo "End Of Script."
cd $pathold
