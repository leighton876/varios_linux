#!/bin/bash
# Necesitas tener instalado wp-cli

clear
wpfile="wp-config.php"
pathold=$(pwd)
pathwww="/var/www"
pathlog="/tmp/wp_update_all.log"
rm $pathlog 2>/dev/null

#adminmail="alejandro@sciremedia.com"
adminmail="jorge@sciremedia.com"

blist=( epf elpuntofrio )
#echo ${blist[@]}
blisted="False"

for site in $(ls $pathwww); do
    pathnow="$pathwww/$site"
    cd $pathnow
    # si esta blaclisted entonces activo blisted:
    if [[ "$(echo ${blist[@]} | grep -ic $site)" > "0" ]];then
        echo "$site is blacklisted!"
        blisted="True"
    fi
    # entramos y lo hacemos si no esta blacklisted:
    if [ -f "$wpfile" ] && [ "$blisted" != "True" ]; then
        chkandup=$(wp plugin update --all --path="$pathnow" | tee "$pathlog" | wc -l)
        readlog=$(cat $pathlog)
        if [ "$chkandup" != "1" ]; then
            echo "$pathnow Actualizado!"
            echo -e "Wordpres: $pathnow UPDATED! \n Report:\n\n $readlog." | mail -s "Wordpress $pathwp Actualizado" $adminmail
        fi
    fi
    blisted="False"
done

cd $pathold
