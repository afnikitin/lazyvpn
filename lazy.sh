#!/bin/bash
set +x

echo "lazyVPN installer (OpenVPN based) v0.1"
echo -e "Press any key to continue \c"
read GO

echo "============================="
echo "Step 0: package installation"
echo "openvpn, openssl, easy-rsa packages are going to be installed"
echo -e "Press any key to continue \c"
read GO

HOME="/home/lazyvpn"
PATHVPN="/etc/openvpn"
PATHRSA="\/etc\/openvpn\/easy-rsa"

set -x
apt-get -y install openvpn openssl easy-rsa
mkdir $PATHVPN"/easy-rsa/"
cp -r /usr/share/easy-rsa/* $PATHVPN"/easy-rsa/"
cp $HOME"/_vars" $HOME"/vars"
set +x

echo "============================="
echo "Step 1: setting up variables"
echo "Setting up VARS file:"
echo "This part is IMPORTANT - do not leave blank fields otherwise you couldn't be available to create keys"
	echo -e "Enter country desired: \c"
	read COUNTRY			#return $COUNTRY
	echo -e "Enter province desired: \c"
	read PROVINCE			#return $PROVINCE
	echo -e "Enter city desired: \c"
	read CITY				#return $CITY
	echo -e "Enter organization desired: \c"
	read ORG				#return $ORG
	echo -e "Enter email desired: \c"
	read EMAIL				#return $EMAIL
	echo -e "Enter organizational unit desired: \c"
	read ORGUNIT			#return $ORGUNIT
	echo "Set RSA key size:"
	echo "1: 1024 bit (default)"
	echo "2: 2048 bit"
	echo "3: 4096 bit"
	echo -e "Choose an option: \c"
	read OPT
	case "$OPT" in
		1) echo "1024 bit RSA key"
		KEYSIZE="1024" ;;
		2) echo "2048 bit RSA key"
		KEYSIZE="2048" ;;
		3) echo "4096 bit RSA key"
		KEYSIZE="4096" ;;
		*) echo "1024 bit RSA key"
		KEYSIZE="1024" ;;
	esac							#return $KEYSIZE

sed -i "s/@PATHRSA/$PATHRSA/g" $HOME"/vars"
sed -i "s/@KEYSIZE/$KEYSIZE/g" $HOME"/vars"
sed -i "s/@COUNTRY/$COUNTRY/g" $HOME"/vars"
sed -i "s/@PROVINCE/$PROVINCE/g" $HOME"/vars"
sed -i "s/@CITY/$CITY/g" $HOME"/vars"
sed -i "s/@ORG/$ORG/g" $HOME"/vars"
sed -i "s/@EMAIL/$EMAIL/g" $HOME"/vars"
sed -i "s/@ORGUNIT/$ORGUNIT/g" $HOME"/vars"
cp -f $HOME"/vars" $PATHVPN"/easy-rsa/vars"
chmod +x $PATHVPN"/easy-rsa/vars"

echo "============================="
echo "Step 2: key generating"
echo "Keys generating part is starting now"
echo "Since you've set up VARS file you need just to press ENTER"
echo -e "Press any key to continue \c"
read GO

( cd $PATHVPN"/easy-rsa/" && source vars && touch vars && echo `./clean-all` && echo `./build-ca` && 
	echo "Server key generating process is starting now" &&
	echo "Since you've set up VARS file you need just to press ENTER" &&
	echo "Once you will be asked to sign and save certificates to database press 'Y' key and then ENTER" &&
	echo -e "Press any key to continue" &&
	read GO &&
	echo `./build-key-server server` && 
	echo "Client key generating process is starting now" &&
	echo "Since you've set up VARS file you need just to press ENTER" &&
	echo "Once you will be asked to sign and save certificates to database press 'Y' key and then ENTER" &&
	echo `./build-key client` && 
	echo "Diffie-Helman key generating process is starting now" &&
	echo `./build-dh` )
	
openvpn --genkey --secret $PATHVPN"/easy-rsa/keys/ta.key"
( cd $PATHVPN"/easy-rsa/keys/" && cp server.crt server.key ca.crt dh"$KEYSIZE".pem ta.key "$PATHVPN" )

echo "============================="
echo "Step 3: setting up a server"
echo "Now you're going to set up VPN server. Please choose options desired."
echo "Which port should be used to connect?"
echo "1: port 1194 (default)"
echo "2: other (need to be specified)"
echo -e "Choose an option: \c"
read OPT
IP=$(/bin/hostname -i)
case "$OPT" in
	1) PORT="1194"
	echo "Port $PORT choosen"
	SERVER=$IP" "$PORT ;;
	2) echo -e "Specify port desired: \c"
	read PORT
	SERVER=$IP" "$PORT
	echo "Port $PORT choosen" ;;
	*) PORT="1194"
	SERVER=$IP" "$PORT
	echo "Port $PORT choosen" ;;	#return $PORT, $SERVER
esac
echo "Which protocol should be used during connection?"
echo "1: UDP (default)"
echo "2: TCP"
echo -e "Choose an option: \c"
read OPT
case "$OPT" in
	1) echo "UDP protocol choosen" 
	PROT="udp" ;;
	2) echo "TCP protocol choosen" 
	PROT="tcp" ;;
	*) echo "UDP protocol choosen" 
	PROT="udp" ;;					#return $PROT
esac
echo "Which interface should be used by server to establish connection?"
echo "1: TUN (default)"
echo "2: TAP"
echo -e "Choose an option: \c"
read OPT
case "$OPT" in 
	1) echo "TUN interface choosen"
	IFACE="tun" ;;
	2) echo "TAP interface choosen"
	IFACE="tap" ;;
	*) echo "TUN interface choosen" 
	IFACE="tun" ;;					#return $IFACE
esac
echo "Would you like to use your PC's DNS servers?"
echo "1: Yes (default)"
echo "2: No (need to be specified)"
echo -e "Choose an option: \c"
read OPT
case "$OPT" in 
	1) echo "Client's DNS servers choosen" 
	BYPASS="1" ;;
	2) echo "Specify 2 DNS servers (IP addresses only, e.g 8.8.8.8, 8.8.4.4)"
	echo -e "DNS #1: \c"
	read DNS1
	echo -e "DNS #2: \c"
	read DNS2 ;;
	*) echo "Client's DNS servers choosen" 
	BYPASS="1" ;;				#return $DNS1, $DNS2 or $BYPASS
esac
echo "Which cipher should be used to provide secure connection (most common listed)?"
echo "1: BF-CBC / Blowfish with 128 bit key (default)"
echo "2: AES-128-CBC / AES with 128 bit key"
echo "3: AES-256-CBC / AES with 256 bit key (recommended)"
echo "4: DES-EDE3-CBC / Triple DES with 192 bit key"
echo -e "Choose an option: \c"
read OPT
case "$OPT" in 
	1) echo "BF-CBC cipher choosen"
	CIPH='"BF-CBC"' ;;
	2) echo "AES-128-CBC cipher choosen"
	CIPH='"AES-128-CBC"' ;;
	3) echo "AES-256-CBC cipher choosen"
	CIPH='"AES-256-CBC"' ;;
	4) echo "DES-EDE3-CBC cipher choosen"
	CIPH='"DES-EDE3-CBC"' ;;
	*) echo "BF-CBC cipher choosen"
	CIPH='"BF-CBC"' ;;				#return $CIPH
esac

cp -f $HOME"/_server.conf" $HOME"/server.conf"
cp -f $HOME"/_client.conf" $HOME"/client.conf"

sed -i "s/@PORT/$PORT/g" $HOME"/server.conf"
sed -i "s/@PROT/$PROT/g" $HOME"/server.conf"
sed -i "s/@IFACE/$IFACE/g" $HOME"/server.conf"
sed -i "s/@KEYSIZE/$KEYSIZE/g" $HOME"/server.conf"
sed -i "s/@CIPH/$CIPH/g" $HOME"/server.conf"
if [[ $BYPASS = "1" ]]
	then 
		sed -i "s/@BYPASS/bypass-dhcp/g" $HOME"/server.conf"
		sed -i "s/@C/;/g" $HOME"/server.conf"
	else
		sed -i "s/@BYPASS//g" $HOME"/server.conf"
		sed -i "s/@C//g" $HOME"/server.conf"
		sed -i "s/@DNS1/$DNS1/g" $HOME"/server.conf"
		sed -i "s/@DNS2/$DNS2/g" $HOME"/server.conf"
fi	
cp -f $HOME"/server.conf" $PATHVPN

sed -i "s/@IFACE/$IFACE/g" $HOME"/client.conf"
sed -i "s/@PROT/$PROT/g" $HOME"/client.conf"
sed -i "s/@SERVER/$SERVER/g" $HOME"/client.conf"
sed -i "s/@CIPH/$CIPH/g" $HOME"/client.conf"

GATE=$(/sbin/ip route | awk '/default/ { print $3 }')
echo "============================="
echo "Step 4: final preparation"

iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $GATE -j MASQUERADE
iptables-save

echo "#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1" > /etc/sysctl.conf
sysctl -p

mkdir $HOME"/_tmp" && cp -f $PATHVPN"/easy-rsa/keys/client.crt" $HOME"/_tmp/client.crt" && cp -f $PATHVPN"/easy-rsa/keys/client.key" $HOME"/_tmp/client.key" && cp -f $PATHVPN"/easy-rsa/keys/ca.crt" $HOME"/_tmp/ca.crt" && cp -f $PATHVPN"/easy-rsa/keys/ta.key" $HOME"/_tmp/ta.key" && cp -f $HOME"/client.conf" $HOME"/_tmp/client.ovpn"
( cd $HOME"/_tmp" && tar -cvzf $HOME"/client.tar.gz" client.crt client.key ca.crt ta.key client.ovpn && cd $HOME && rm -rf $HOME"/_tmp/" )
rm -f $HOME"/server.conf" && rm -f $HOME"/client.conf" && rm -f $HOME"/vars"

echo `/etc/init.d/openvpn restart`
echo "VPN server now should be running"
service --status-all | grep openvpn
echo "Download client.tar.gz file from /home directory and extract it"
echo "Move bunch of files into OpenVPN client directory on your PC"
echo -e "Installation complete! Press any key to exit \c"
read GO
