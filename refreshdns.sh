#!/bin/bash
IFS=$'\n'
lxc ls -c n,4 -f csv > tmp.tmp
FICHERO="./tmp.tmp"
for I in $(cat $FICHERO); do
	IP=$(echo -n $I | cut -d"," -f2 | cut -d" " -f1)
	NOMBRE=$(echo -n $I | cut -d"," -f1 )
	LINEA=$(echo "$NOMBRE	IN	A	$IP")
	lxc exec DNS -- cat  /etc/bind/db.lxd | grep $NOMBRE > /dev/null
	if [ $? -eq 0 ]; then
		if ! [ "$NOMBRE" = "DNS" ]; then
	                lxc exec DNS -- sed -i /"$NOMBRE"/d /etc/bind/db.lxd 
        	        LINEAS=$(lxc exec DNS -- cat /etc/bind/db.lxd | wc -l)
                	lxc exec DNS -- sed -i "$LINEAS"a"$LINEA" /etc/bind/db.lxd
	                lxc exec DNS -- systemctl restart bind9
		fi
        else
		if ! [ "$NOMBRE" = "DNS" ]; then
		       LINEAS=$(lxc exec DNS -- cat /etc/bind/db.lxd | wc -l)
        	       	lxc exec DNS -- sed -i "$LINEAS"a"$LINEA" /etc/bind/db.lxd
                	lxc exec DNS -- systemctl restart bind9
		fi
        fi
done
