#!/bin/bash

# Este script es algo similar a Fail2ban pero casero.
# Se puede usar cron para que lo ejecute todos los dias a las 11:00 am
# ejecutamos crontab -e 
# y agregamos lo siguiente al final (sin el primer #) 
# 00 11 * * * /usr/bin/UpdateIPsIPTables.sh
# o cada 3 minutos a todas horas todos los dias:
# */3 * * * * /usr/bin/UpdateIPsIPTables.sh
# para comprobar el cron:
# grep CRON /var/log/syslog
# tiene que salir algo asi: (root) CMD (/usr/bin/UpdateIPsIPTables.sh)

clear
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root"
else
    # El limite maximo de reglas en la realidad creo que son 25000 por eso hago este if de limite
    # -24 reglas predefinidas del flush cache etc pues 24976 es el maximo
    totalreglas=$(grep "Failed password for root" /var/log/auth.log | grep -Po "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | sort | uniq | wc -l )
    #echo $totalreglas
    if [ $totalreglas -le "24976"  ]; then
        # Ips de confianza aqui:    
        IP1="xxx.xxx.xxx.xxx"
        IP2="xxx.xxx.xxx.xxx"
        IP3="xxx.xxx.xxx.xxx"

        echo "#!/bin/bash" > /etc/init.d/firewall
        echo " " >> /etc/init.d/firewall
        echo "# Primero borramos todas las reglas previas que puedan existir" >> /etc/init.d/firewall
        echo "iptables -F" >> /etc/init.d/firewall
        echo "iptables -X" >> /etc/init.d/firewall
        echo "iptables -Z" >> /etc/init.d/firewall
        echo "iptables -t nat -F" >> /etc/init.d/firewall
        echo " " >> /etc/init.d/firewall
        echo "# Después definimos que la politica por defecto sea ACEPTAR" >> /etc/init.d/firewall
        echo "iptables -P INPUT ACCEPT" >> /etc/init.d/firewall
        echo "iptables -P OUTPUT ACCEPT" >> /etc/init.d/firewall
        echo "iptables -P FORWARD ACCEPT" >> /etc/init.d/firewall
        echo "iptables -t nat -P PREROUTING ACCEPT" >> /etc/init.d/firewall
        echo "iptables -t nat -P POSTROUTING ACCEPT" >> /etc/init.d/firewall
        echo " " >> /etc/init.d/firewall
        echo "# Para evitar errores en el sistema, debemos aceptar" >> /etc/init.d/firewall
        echo "# todas las comunicaciones por la interfaz lo (localhost)" >> /etc/init.d/firewall
        echo "iptables -A INPUT -i lo -j ACCEPT" >> /etc/init.d/firewall
        echo " " >> /etc/init.d/firewall
        echo "# Denegando el acceso por ssh a ciertas ips atacantes o boots:" >> /etc/init.d/firewall

        # Para saber cuantas veces usaremos este:
        # grep "Failed password for root" /var/log/auth.log | grep -Po "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | sort | uniq -c
        grep "Failed password for root" /var/log/auth.log | grep -Po "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | sort | uniq > /tmp/BruteForceIPAttacks.txt

        rm /tmp/BruteForceIPAttacksIPTables_Rules.txt
        prefijo="iptables -A INPUT -s "
        sufijo=" -p tcp --dport 22 -j DROP"
        #while read laip; do echo "$prefijo$laip$sufijo" ; done < /tmp/BruteForceIPAttacks.txt | tee /tmp/BruteForceIPAttacksIPTables_Rules.txt
        while read laip; do echo "$prefijo$laip$sufijo" ; done < /tmp/BruteForceIPAttacks.txt > /tmp/BruteForceIPAttacksIPTables_Rules.txt
        #egrep -v "$IP1|$IP2|$IP3" /BruteForceIPAttacksIPTables_Rules.txt | tee -a /etc/init.d/firewall
        egrep -v "$IP1|$IP2|$IP3" /tmp/BruteForceIPAttacksIPTables_Rules.txt >> /etc/init.d/firewall

        echo " " >> /etc/init.d/firewall
        echo "# Comprobamos cómo quedan las reglas" >> /etc/init.d/firewall
        echo "iptables -L -n -v" >> /etc/init.d/firewall

        echo "Ejecutando el nuevo script..."
        sh /etc/init.d/firewall
        exit
    else
        echo "You have exceeded the maximum limit of rules for iptables!!" | tee /var/log/firewall.log
    fi
fi
