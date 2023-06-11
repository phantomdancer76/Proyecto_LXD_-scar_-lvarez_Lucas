#!/bin/bash
NOMBREMAQ=$1
DISTRIBUCION=$2
echo $NOMBREMAQ
echo $DISTRIBUCION
if  [ '$NOMBREMAQ' != '' ] |  [ '$DISTRIBUCION' != '' ]; then
	lxc launch $DISTRIBUCION $NOMBREMAQ
	sleep 15
	lxc exec $NOMBREMAQ apt update
	lxc exec $NOMBREMAQ apt upgrade < confirmacion.txt
	lxc exec $NOMBREMAQ apt install ftp < confirmacion.txt
	lxc config device add $NOMBREMAQ eth0 nic nictype=bridged parent=br0 name=eth0
	sleep 4
	IP=$(lxc ls -c n,4 | grep $NOMBREMAQ | cut -d"|" -f3 | cut -d" " -f2)
	lxc exec DNS -- cat /etc/bind/db.lxd | grep $NOMBREMAQ
	if [ $? -eq 0 ]; then
		lxc exec DNS -- sed -i /"$NOMBREMAQ"/d /etc/bind/db.lxd 
		LINEAS=$(lxc exec DNS -- cat /etc/bind/db.lxd | wc -l)
		lxc exec DNS -- sed -i "$LINEAS"a"$NOMBREMAQ	IN	A	$IP" /etc/bind/db.lxd
		lxc exec DNS -- systemctl restart bind9
	else
		LINEAS=$(lxc exec DNS -- cat /etc/bind/db.lxd | wc -l)
		lxc exec DNS -- sed -i "$LINEAS"a"$NOMBREMAQ	IN	A	$IP" /etc/bind/db.lxd
		lxc exec DNS -- systemctl restart bind9
 	fi
else
echo "necesitas un parámetro que es el nombre de máquina o una distribucion"
fi
