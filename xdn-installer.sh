#!/bin/bash
###
SCRIPTVER=1.0.2
CONFIG_FILE='DigitalNote.conf'
CONFIGFOLDER=$(eval echo $HOME/.XDN)
CFFULLPATH=$(eval echo $CONFIGFOLDER/$CONFIG_FILE)
COIN_DAEMON='DigitalNoted'
COIN_PATH='/usr/local/bin/'
COIN_GIT='https://github.com/DigitalNoteXDN/DigitalNote-2 DigitalNote'
COIN_BACKUP='~/DigitalNoteBackup'
COIN_NAME='DigitalNote'
COIN_PORT=18092
RPC_PORT=18094
COIND_COMMAND=$(eval echo $COIN_PATH$COIN_DAEMON)
STARTCMD=$(eval echo $COIND_COMMAND)
STOPCMD=$(eval echo $COIND_COMMAND stop)
PFile=$(eval echo $CONFIGFOLDER/$COIN_NAME.pid)
NODEIP=$(curl -s4 icanhazip.com)
WHITE="\033[0;37m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
UYELLOW="\033[4;33m"
CYAN="\033[0;36m"
PURPLE="\033[0;35m"
PURPLEB="\033[1;35m"
RED='\033[0;31m'
GREEN="\033[0;32m"
UGREEN="\033[4;32m"
NC='\033[0m'
Off='\E[0m'
Bold='\E[1m'
Dim='\E[2m'
Underline='\E[4m'
Blink='\E[5m'
Reverse='\E[7m'
Strike='\E[9m'
FgBlack='\E[39m'
FgRed='\E[31m'
FgGreen='\E[32m'
FgYellow='\E[33m'
FgBlue='\E[34m'
FgMagenta='\E[35m'
FgCyan='\E[36m'
FgWhite='\E[37m'
BgBlack='\E[40m'
BgRed='\E[41m'
BgGreen='\E[42m'
BgYellow='\E[43m'
BgBlue='\E[44m'4
BgMagenta='\E[45m'
BgCyan='\E[46m'
BgWhite='\E[47m'
FgLtBlack='\E[90m'
FgLtRed='\E[91m'
FgLtGreen='\E[92m'
FgLtYellow='\E[93m'
FgLtBlue='\E[94m'
FgLtMagenta='\E[95m'
FgLtCyan='\E[96m'
FgLtWhite='\E[97m'
BgLtBlack='\E[100m'
BgLtRed='\E[101m'
BgLtGreen='\E[102m'
BgLtYellow='\E[103m'
BgLtBlue='\E[104m'
BgLtMagenta='\E[105m'
BgLtCyan='\E[106m'
BgLtWhite='\E[107m'

function purgeOldInstallation() {
echo -e "${GREEN}Searching and removing old $COIN_NAME files and making a config backup to $HOME/DigitalNoteBackup if they exist ${NC}"
if [[ -f $(eval echo $CONFIGFOLDER/wallet.dat) ]]; then
    echo -e "Exists, making backup${NC}" 
if [[ ! -d $(eval echo $COIN_BACKUP) ]]; then    
mkdir $(eval echo $COIN_BACKUP)
fi
    cp  $(eval echo $CFFULLPATH $COIN_BACKUP ) 2> /dev/null
    cp  $(eval echo $CONFIGFOLDER/DigitalNote.conf $COIN_BACKUP ) 2> /dev/null
    cp $(eval echo $CONFIGFOLDER/wallet.dat $COIN_BACKUP ) 2> /dev/null
fi
    #kill wallet daemon
    $COIN_DAEMON stop > /dev/null 2>&1
    #sudo killall $COIN_DAEMON > /dev/null 2>&1
	# Save Key
	if [! $JUSTWALLET ]; then
	OLDKEY=$(awk -F'=' '/masternodeprivkey/ {print $2}' $CFFULLPATH 2> /dev/null)
	if [[ $OLDKEY ]]; then
    		echo -e "${CYAN}Saving Old Installation Genkey ${WHITE} $OLDKEY"
	fi
	fi
    #remove old ufw port allow
    sudo ufw delete allow $COIN_PORT/tcp > /dev/null 2>&1
    #remove old files
    #sudo rm -rf $CONFIGFOLDER > /dev/null 2>&1
    sudo rm -rf /usr/local/bin/$COIN_DAEMON > /dev/null 2>&1
    [ -d $CONFIGFOLDER  ] || mkdir $CONFIGFOLDER 
    sudo rm -rf ~/DigitalNote
	sudo rm -f db-6.2.32.NC.tar.gz*
echo -e "${GREEN}* Done${NONE}";
}


function memorycheck() {

echo -e "${GREEN}Checking Memory${NC}"
FREEMEM=$(free -m |sed -n '2,2p' |awk '{ print $4 }')
SWAPS=$(free -m |tail -n1 |awk '{ print $2 }')

if [[ $FREEMEM -lt 3096 ]]; then 
	if [[ $SWAPS -eq 0 ]]; then
		echo -e "${GREEN}Adding swap${NC}"
		fallocate -l 3G /swapfile
		chmod 600 /swapfile
		mkswap /swapfile
		swapon /swapfile
		cp /etc/fstab /etc/fstab.bak
		echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
	else
		echo -e "Got ${WHITE}$SWAPS${GREEN} swap"
		if [[ $SWAPS -lt 2046 ]]; then
			echo -e "${YELLOW}But thats less than what we want, so increasing swap to correct size to allow compile to succeed"
			ADDSWAPS=$((2048 - $SWAPS))
			if [[ $ADDSWAPS -lt 1024 ]]; then 
				ADDSWAPS=1024
			fi
			fallocate -l $ADDSWAPS /swapfile2
			chmod 600 /swapfile2
			mkswap /swapfile2
			swapon /swapfile2
			cp /etc/fstab /etc/fstab.bak
			echo '/swapfile2 none swap sw 0 0' | sudo tee -a /etc/fstab
		fi 
		echo -e "${WHITE}And thats enough swap that compile should work"
	fi
	else
	echo -e "Enough free ram available for compile to succeed, not checking swap"
fi 
}

function download_node() {
  
  echo -e " "
  echo -e " "
  echo -e " "
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${GREEN}Starting VPS Build for ${PURPLEB}$COIN_NAME${NC}"
  echo -e "${BLUE}================================================================${NC}"
  sleep 5 
  echo -e " "
  echo -e " "
  echo -e " "
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${GREEN}Installing Dependencies${NC}"
  echo -e "${BLUE}================================================================${NC}"


  sleep 5
  apt update > /dev/null 2>&1
  cd ~
  sudo apt-get install -y ntp git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev libcurl4-openssl-dev curl libzip-dev; apt-get update -y
  apt-get install -y git make automake build-essential libboost-all-dev
  apt-get install -y yasm binutils libcurl4-openssl-dev openssl libssl-dev
  sudo apt-get install -y libgmp-dev 
  sudo apt-get install -y libtool

  echo -e " "
  echo -e " "
  echo -e " "
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${GREEN}Building and Linking Dependencies${NC}"
  echo -e "${BLUE}================================================================${NC}"
  echo -e " "
  sleep 5
  cd ~
  wget http://download.oracle.com/berkeley-db/db-6.2.32.NC.tar.gz
  tar zxf db-6.2.32.NC.tar.gz
  cd db-6.2.32.NC/build_unix
  ../dist/configure --enable-cxx
  make
  sudo make install
  sudo ln -s /usr/local/BerkeleyDB.6.2/lib/libdb-6.2.so /usr/lib/libdb-6.2.so
  sudo ln -s /usr/local/BerkeleyDB.6.2/lib/libdb_cxx-6.2.so /usr/lib/libdb_cxx-6.2.so
  export BDB_INCLUDE_PATH="/usr/local/BerkeleyDB.6.2/include"
  export BDB_LIB_PATH="/usr/local/BerkeleyDB.6.2/lib"
  echo -e " "
  echo -e " "
  echo -e " "
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${GREEN}Github Pull (Source Download)${NC}"
  echo -e "${BLUE}================================================================${NC}"
  echo -e " "
  sleep 5
  cd ~
  git clone -b release --single-branch $COIN_GIT
  echo -e " "
  echo -e " "
  echo -e " "
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${GREEN}Build DigitalNote Daemon${NC}"
  echo -e "${BLUE}================================================================${NC}"
  echo -e " "
  sleep 5
  cd ~
  cd ~/DigitalNote/src 
  chmod a+x obj
  chmod a+x leveldb/build_detect_platform
  chmod a+x secp256k1; chmod a+x leveldb
  chmod a+x ~/DigitalNote/src
  chmod a+x ~/DigitalNote
  make -f makefile.unix USE_UPNP=-
  cd ~
  cp -r ~/DigitalNote/src/DigitalNoted /usr/local/bin/DigitalNoted

}

function stopdaemon() {

DAEMONPID=$(pidof DigitalNoted)

if [[ -z $DAEMONPID ]]; then
echo -e "Daemon not currently running, Good!"
else
echo -e "Stopping running daemon"
$COIN_DAEMON stop > /dev/null 2>&1
sleep 10
kill -9 $DAEMONPID > /dev/null 2>&1
kill -15 $DAEMONPID > /dev/null 2>&1
fi

}

function startdaemon() {

  $COIN_DAEMON > /dev/null 2>&1


  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}$COIN_NAME is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo -e "${GREEN}$COIN_DAEMON"
    echo -e "$COIN_DAEMON getinfo"
    exit 1
  fi
}

function create_config() {


if [[ ! -d $(eval echo $CONFIGFOLDER) ]]; then    
echo -e "Making Config Folder"
mkdir $(eval echo $CONFIGFOLDER)
fi
clear
echo -e " "
echo -e "${BLUE}================================================================${NC}"
echo -e "${RED}$COIN_NAME ${YELLOW}RPC Username Creation${NC}."
echo -e "${BLUE}================================================================${NC}"
echo -e "${YELLOW}Enter your ${RED}$COIN_NAME RPC Username${NC}."
echo -e "${WHITE}Please create a RPC Username to use for this Daemon"
echo -e "If left blank, once will be created for you"
read -rp "RPC Username: " RPCUSER
if [[ ($RPCUSER == "") ]]
then
	RPCUSER=$(openssl rand -hex 11)
fi
  echo -e " "
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${RED}$COIN_NAME ${YELLOW}RPC Password Creation${NC}."
  echo -e "${BLUE}================================================================${NC}"
echo -e "${YELLOW}Enter your ${RED}$COIN_NAME RPC Password${NC}."
echo -e "${WHITE}Please create a complex RPC Password to use for this Daemon"
echo -e "If left blank, once will be created for you"
read -rp "RPC Password: " RPCPASSWORD
if [[ ($RPCPASSWORD == "") ]]
then
	RPCPASSWORD=$(openssl rand -hex 20)
fi


RPCPORT=$(netstat --listening -n |grep $RPC_PORT)
if [[ ! -z RPCPORT ]]; then
echo -e "Port $RPC_PORT is clear!"
else
echo -e "Something is listening on the RPC Port: $RPC_PORT."
RPC_PORT=$((($RPC_PORT) + 10))
echo -e "moving RPC port to $RPC_PORT"
fi
echo -e "${GREEN}Generating Config at $CFFULLPATH ${NC}"
MASTERNODEIP=$(eval echo $NODEIP:$COIN_PORT)

  cat << EOF > $(eval echo $CONFIGFOLDER/$CONFIG_FILE)
listen=1
server=1
daemon=1
testnet=0
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcport=18094
port=$COIN_PORT
rpcconnect=127.0.0.1
rpcallowip=127.0.0.1
masternode=1 
externalip=$NODEIP
bind=$NODEIP
masternodeaddr=$MASTERNODEIP
masternodeprivkey=$COINKEY
addnode=157.230.107.144:18092
addnode=138.197.161.183:18092
addnode=188.166.123.46:18092
addnode=159.203.14.113:18092
addnode=31.171.244.174:18092
addnode=209.189.77.193:18092
addnode=104.248.186.130:18:18092
addnode=104.248.186.130:18092
addnode=142.44.198.11:18092
addnode=142.44.198.13:18092
addnode=142.44.198.148:18092
addnode=142.44.198.176:18092
addnode=142.44.198.177:18092
EOF

echo -e "Done"
}

function create_wallet_config() {


if [[ ! -d $(eval echo $CONFIGFOLDER) ]]; then    
echo -e "Making Config Folder"
mkdir $(eval echo $CONFIGFOLDER)
fi
clear
echo -e " "
echo -e "${BLUE}================================================================${NC}"
echo -e "${RED}$COIN_NAME ${YELLOW}RPC Username Creation${NC}."
echo -e "${BLUE}================================================================${NC}"
echo -e "${YELLOW}Enter your ${RED}$COIN_NAME RPC Username${NC}."
echo -e "${WHITE}Please create a RPC Username to use for this Daemon"
echo -e "If left blank, once will be created for you"
read -rp "RPC Username: " RPCUSER
if [[ ($RPCUSER == "") ]]
then
	RPCUSER=$(openssl rand -hex 11)
fi
  echo -e " "
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${RED}$COIN_NAME ${YELLOW}RPC Password Creation${NC}."
  echo -e "${BLUE}================================================================${NC}"
echo -e "${YELLOW}Enter your ${RED}$COIN_NAME RPC Password${NC}."
echo -e "${WHITE}Please create a complex RPC Password to use for this Daemon"
echo -e "If left blank, once will be created for you"
read -rp "RPC Password: " RPCPASSWORD
if [[ ($RPCPASSWORD == "") ]]
then
	RPCPASSWORD=$(openssl rand -hex 20)
fi


RPCPORT=$(netstat --listening -n |grep $RPC_PORT)
if [[ ! -z RPCPORT ]]; then
echo -e "Port $RPC_PORT is clear!"
else
echo -e "Something is listening on the RPC Port: $RPC_PORT."
RPC_PORT=$((($RPC_PORT) + 10))
echo -e "moving RPC port to $RPC_PORT"
fi
echo -e "${GREEN}Generating Config at $CFFULLPATH ${NC}"
MASTERNODEIP=$(eval echo $NODEIP:$COIN_PORT)

  cat << EOF > $(eval echo $CONFIGFOLDER/$CONFIG_FILE)
listen=1
server=1
testnet=0
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcport=18094
port=$COIN_PORT
rpcconnect=127.0.0.1
rpcallowip=127.0.0.1
addnode=157.230.107.144:18092
addnode=138.197.161.183:18092
addnode=188.166.123.46:18092
addnode=159.203.14.113:18092
addnode=31.171.244.174:18092
addnode=209.189.77.193:18092
addnode=104.248.186.130:18:18092
addnode=104.248.186.130:18092
addnode=142.44.198.11:18092
addnode=142.44.198.13:18092
addnode=142.44.198.148:18092
addnode=142.44.198.176:18092
addnode=142.44.198.177:18092
EOF

echo -e "Done"
}

function create_key() {
if [[ $OLDKEY ]]; then
  echo -e " "
  echo -e " "
  echo -e " "
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${GREEN}We have a previous MASTENODE GENKEY... ${YELLOW}$OLDKEY"
  echo -e "${BLUE}================================================================${YELLOW}"
  echo -e " "
  read -rp "Would you like to use that? [Y/n]" USEEXISTINGKEY

if [[ ("$USEEXISTINGKEY" == "y" || "$USEEXISTINGKEY" == "Y") ]]
then
    COINKEY=$OLDKEY
else
	OLDKEY=""
fi
fi

	if [[ ! $OLDKEY ]]; then 
		clear
		echo -e " "
		echo -e "${RED}$COIN_NAME ${YELLOW}Masternode GENKEY Input${NC}."
		while [[ -z "$COINKEY" ]]; do
		echo -e "============================================================="
		echo -e "${YELLOW}Enter your new ${RED}$COIN_NAME ${YELLOW}Masternode GENKEY${NC}."
		echo -e "${WHITE}Please start your local wallet and go to"
		echo -e "Tools -> Debug Console and type ${GREEN}masternode genkey${WHITE}"
		echo -e "And please copy the string of letters and numbers"
		read -rp "and enter it here: " COINKEY
		done
	fi
	
#clear
}

function wallet_replace() {
if [ -d $(eval echo $COIN_BACKUP) ]; then 
echo -e "${GREEN} Putting wallet.dat back"
cp $(eval echo $COIN_BACKUP/wallet.dat $CONFIGFOLDER )
fi 

}

function enable_firewall() {
  echo -e "Installing and setting up firewall to allow ingress on port ${GREEN}$COIN_PORT${NC}"
  sudo ufw default deny incoming;
  sudo ufw default allow outgoing;
  sudo ufw allow ssh/tcp;
  sudo ufw limit ssh/tcp  comment "Rate limit for openssh server";
  sudo ufw allow ftp;
  sudo ufw limit ftp/tcp  comment "Rate limit for ftp server";
  sudo ufw allow $COIN_PORT/tcp comment "$COIN_NAME MN port";
  sudo ufw logging on;
  sudo ufw --force enable;
}


function get_ip() {
  declare -a NODE_IPS
  for ips in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
  do
    NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s4 icanhazip.com))
  done

  if [ ${#NODE_IPS[@]} -gt 1 ]
    then
      echo -e "${GREEN}More than one IP. Please type 0 to use the first IP, 1 for the second and so on...${NC}"
      INDEX=0
      for ip in "${NODE_IPS[@]}"
      do
        echo ${INDEX} $ip
        let INDEX=${INDEX}+1
      done
      read -e choose_ip
      NODEIP=${NODE_IPS[$choose_ip]}
  else
    NODEIP=${NODE_IPS[0]}
  fi
}


function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC}"
  exit 1
fi
}


function checks() {
BUILD=$(lsb_release -r)
if [[ "$BUILD" != *16.04* && "$BUILD" != *18.04* ]]
then
  	echo -e "You are not running a supported version of Ubuntu. Installation is cancelled."
  	exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root (sudo -i and rerun script).${NC}"
   exit 1
fi

}


function important_information() {
if [ $JUSTWALLET ]; then
 INSTALLER="Wallet"
else
 INSTALLER="Masternode"
fi
 clear
 echo -e " "
 echo -e "${BLUE}================================================================${NC}"
 echo -e "${PURPLEB}Windows Wallet Guide. ${UYELLOW}https://www.digitalnote.biz/xdn/pdf/DigitalNote_Wallet_Guide.pdf ${Off}${NC}"
 echo -e "${BLUE}================================================================${NC}"
 echo -e "${GREEN}$COIN_NAME $INSTALLER is up and running listening on port ${NC}${PURPLEB}$COIN_PORT${NC}."
 echo -e "${GREEN}Configuration file is: ${NC}${PURPLEB}$CFFULLPATH${NC}"
 echo -e "${GREEN}Start: ${NC}${PURPLEB}$COIN_DAEMON${NC}"
 echo -e "${GREEN}Stop: ${NC}${PURPLEB}$COIN_DAEMON stop${NC}"
 echo -e "${GREEN}VPS_IP:PORT ${NC}${PURPLEB}$NODEIP:$COIN_PORT${NC}"
if [ ! $JUSTWALLET ]; then
if [[ ! $OLDKEY ]]; then
 echo -e "${GREEN}***NEW*** MASTERNODE GENKEY is: ${NC}${PURPLEB}$COINKEY${NC}"
else
 echo -e "${GREEN}Copied from previous config MASTERNODE GENKEY is: ${NC}${PURPLEB}$COINKEY${NC}"
fi
fi
 echo -e "${BLUE}================================================================${YELLOW}"
 read -rp "Press any key to continue" pause
 clear
 echo -e " "
 echo -e " "
 echo -e "Updated for ${PURPLEB}XDN ${WHITE}by ${YELLOW}Rubber-Duckie ${WHITE}using original script from RealBiYoda (DragonLady update)"
 echo -e "${BLUE}================================================================${NC}"
 echo -e "${RED}Ensure Node is fully SYNCED with BLOCKCHAIN.${NC}"
 echo -e "${BLUE}================================================================${NC}"
 echo -e "${GREEN}Usage Commands:${NC}"
 echo -e "${PURPLEB}DigitalNoted${NC}"
 echo -e "${PURPLEB}DigitalNoted getinfo${NC}"
 echo -e "${BLUE}================================================================${NC}"
 echo -e "${YELLOW}Donations always accepted gratefully.${NC}"
 echo -e "${BLUE}================================================================${NC}"
 echo -e "${YELLOW}Rubber-Duckie: ${WHITE}dS3voFtYMohSD1nPfqamwXRHLQnvipam7e${NC}"
 echo -e "${BLUE}================================================================${NC}"


}



function support() {
memfree=$(free -m |sed -n '2,2p' |awk '{ print $4 }')
swapspace=$(free -m |tail -n1 |awk '{ print $2 }')
getinfo=$(/usr/local/bin/DigitalNoted getinfo)
last20=$(tail ~/.XDN/debug.log -n20)

echo -e "${BLUE}================================================================${NC}"
 echo -e "${PURPLEB}XDN ${Blink}${FgLtWhite}Support${Off}${FgLtWhite}${BgLtBlue} ${FgLtRed}Help ${Off}${FgLtWhite}${BgLtBlue}Screen"
echo -e "${BLUE}================================================================${NC}"
echo -e  "                                                                                                          "
echo -e  " Getinfo: $getinfo                                                                                                      "
echo -e  "                                                                                                          "
echo -e  "Free Memory: $memfree  		Swap Space: $swapspace  "
echo -e  " "
echo -e  "                                                                                                          "

}

function mainmenu() {
clear
echo -e " "
echo -e "${YELLOW}Welcome to the linux installer for ${PURPLEB}DigitalNote (XDN)${NC}..."
echo -e " "
echo -e "                      ${PURPLEB}███████  ${WHITE}${Bold}███████  ███████"
echo -e "                      ${PURPLEB}███████  ${WHITE}${Bold}███████  ███████"
echo -e "                      ${PURPLEB}███████  ${WHITE}${Bold}███████  ███████"
echo -e "								   "
echo -e "                     ${PURPLEB}          ███████  ${WHITE}${Bold}███████"
echo -e "                     ${PURPLEB}          ███████  ${WHITE}${Bold}███████"
echo -e "                     ${PURPLEB}          ███████  ${WHITE}${Bold}███████"
echo -e "                      							"
echo -e "	 	     ${PURPLEB}                   ███████"
echo -e "                     ${PURPLEB}                   ███████"
echo -e "                     ${PURPLEB}                   ███████"

echo -e " "
 echo -e "${BLUE}================================================================${NC}"
 echo -e "${WHITE}Main Menu"
 echo -e "${BLUE}===================${WHITE}Here are your options${BLUE}========================${NC}"
 echo -e "${GREEN}1:${NC}${FgLtYellow} Install / Update Masternode${NC}"
 echo -e "${GREEN}2:${NC}${FgLtYellow} Install NTP Service (Optional but reccommended)${NC}"
 echo -e "${GREEN}3:${NC}${FgLtYellow} Just install wallet cli${NC}"
 echo -e "${GREEN}4:${NC}${FgLtYellow} Quit and get me out of here${NC}"
 echo -e "${BLUE}================================================================${NC}"
}

function mainmenu2 {
#PS3='Please enter your choice: '
#options=("Install full Masternode" "Quit and get me out of here")
shouldloop=true;
while $shouldloop; do
mainmenu
read -rp "Please select your choice: " opt

    case $opt in
        "1")
            echo "Lets do a masternode!";
	doamasternode
	    echo -e "${Underline}Masternode Setup ${Blink}${UGREEN}Complete${Off}$!!!"
            read -rp "Press any key to return to main menu" pause
            echo -e "${NC}Returning you to the shell"
	    ;;
        "2")
            echo "NTP Service Installation and Confuguration";
	addNTPService
	    read -rp "Press any key to return to main menu" pause
         ;;
	    "3")
            echo "Wallet CLI Only!";
	justwallet
	    echo -e "${Underline}CLI Wallet Setup ${Blink}${UGREEN}Complete${Off}$!!!"
            read -rp "Press any key to return to main menu" pause
            echo -e "${NC}Returning you to the shell"
	    ;;
        "4")
            echo "Returning you to the shell";
	shouldloop=false;
	break
	exit
	;;
	 "jump")
	echo -e "Where do you want to jump to?"
	echo -e "Valid examples are"
	echo -e "logo"
	echo -e "important_information"
	echo -e "configure_systemd"
	echo -e "preflightchecks"
	echo -e ""
	echo -e ""
        read -rp "Jump to what function?: " jump;
        $jump
	read -rp "press any key to continue" pause;
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
}

function addNTPService() {
clear
  echo -e " "
  echo -e "${RED}================================================================${NC}"
  echo -e "${RED}===========================* WARNING *==========================${NC}"
  echo -e "${RED}================================================================${NC}"
  echo -e " "
  echo -e "${YELLOW}This section is designed to be implemented on a new/fresh system!!"
  echo -e " "
  echo -e "If you have already made updates to your NTP config file manually then please"
  echo -e "quit out of this section and perform the steps manually."
  echo -e "Please refer to Appendix A of the Maternodes guide for manual instructions.${NC}"
  echo -e " "
  read -rp "Would you like to continue? [Y/n]: " CONTINUE
  if [[ ($CONTINUE == "Y" || $CONTINUE == "y") ]]
  then
  clear
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${YELLOW}Input Regional NTP Servers${NC}."
  echo -e "${BLUE}================================================================"
  echo -e "${YELLOW}Enter your new NTP Servers${NC}."
  echo -e " "
  echo -e "${WHITE}Please go to ${UYELLOW}https://www.ntppool.org/zone/@${NC}"
  echo -e "Navigate to the zone then country your VPS is in and enter the servers below"
  echo -e "Just add the server name - not the word 'server'"
  echo -e "EXAMPLE: For Australia:"
  echo -e " "
  echo -e "${YELLOW}0.au.pool.ntp.org"
  echo -e "1.au.pool.ntp.org"
  echo -e "2.au.pool.ntp.org"
  echo -e "3.au.pool.ntp.org${NC}"
  echo -e " "
  echo -e " "
  read -rp "Enter Server '0': " SERVER0
  read -rp "Enter Server '1': " SERVER1
  read -rp "Enter Server '2': " SERVER2
  read -rp "Enter Server '3': " SERVER3
clear
  echo -e " "
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${YELLOW}The following section makes changes to both your /etc/ntp.conf file"
  echo -e "and adds entries to iptables"
  echo -e " "
  echo -e "It is designed to add a basic NTP Service and lockdowns to ensure time"
  echo -e "is synced on your masternode"
  echo -e " ${WHITE}"
  read -rp "press any key to read more" pause;
  clear
  echo -e "${PURPLEB}Changes to etc/ntp.conf:${YELLOW}"
  echo -e " "
  echo -e "in ${PURPLEB}'Specify one or more NTP servers.'${YELLOW} section:"
  echo -e " "
  echo -e "Changes:"
  echo -e " "
  echo -e "${WHITE}pool 0.ubuntu.pool.ntp.org iburst"
  echo -e "pool 1.ubuntu.pool.ntp.org iburst"
  echo -e "pool 2.ubuntu.pool.ntp.org iburst"
  echo -e "pool 3.ubuntu.pool.ntp.org iburst"
  echo -e " "
  echo -e "${YELLOW}to:"
  echo -e " "
  echo -e "${WHITE}server $SERVER0 iburst"
  echo -e "server $SERVER1 iburst"
  echo -e "server $SERVER2 iburst"
  echo -e "server $SERVER3 iburst"
  echo -e " "
  echo -e "${YELLOW}and comments out section ${PURPLEB}'Use Ubuntu's ntp server as a fallback.'${YELLOW}:"
  echo -e " "
  echo -e "${WHITE}pool ntp.ubuntu.com"
  echo -e " "
  read -rp "press any key to read more" pause;
  clear
  echo -e " "
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${YELLOW}This script also adds iptable entries"
  echo -e "(ensuring NTP is locked down only to your time servers)"
  echo -e "Please review Appendix A of Masternode guide to familiarise"
  echo -e "yourself with the changes"
  echo -e " "
  echo -e "This information is added and NTP restarted"
  echo -e "with the command ${PURPLEB}'systemctl restart ntp.service'"
  echo -e "${YELLOW}If you do not want this to happen, or would rather do it manually," 
  echo -e "please exit now${WHITE}"
  echo -e " "
  read -rp "Exit? [y/N]: " EXITNTP
  if [[ ($EXITNTP == "N" || $EXITNTP == "n" || $EXITNTP == "") ]]
  then
  echo -e " "
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${GREEN}Starting NTP Build for ${PURPLEB}$COIN_NAME${NC}"
  echo -e "${BLUE}================================================================${NC}"
  sleep 5 
  echo -e " "
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${GREEN}Updating System${NC}"
  echo -e "${BLUE}================================================================${NC}"
  sleep 5
  cd ~
  sudo apt-get update
  echo -e " "
  echo -e " "
  echo -e " "
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${GREEN}Installing NTP Services ${NC}"
  echo -e "${BLUE}================================================================${NC}"
  sleep 5
  sudo apt-get install ntp ntpdate
  clear
  echo -e " "
  echo -e " "
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${GREEN}Configuring NTP${NC}"
  echo -e "${BLUE}================================================================${NC}"
  sleep 5
  cd ~
  cd /etc
  sed -i "s/pool 0.ubuntu.pool.ntp.org iburst/server $SERVER0 iburst/g" ntp.conf
  sed -i "s/pool 1.ubuntu.pool.ntp.org iburst/server $SERVER1 iburst/g" ntp.conf
  sed -i "s/pool 2.ubuntu.pool.ntp.org iburst/server $SERVER2 iburst/g" ntp.conf
  sed -i "s/pool 3.ubuntu.pool.ntp.org iburst/server $SERVER3 iburst/g" ntp.conf
  sed -i "s/pool ntp.ubuntu.com/#pool ntp.ubuntu.com/g" ntp.conf
  
  sudo ufw allow 123/udp
  iptables -A INPUT -p udp --destination-port 123 -j DROP
  iptables -A INPUT -p udp -s $SERVER0 --sport ntp -m state --state ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p udp -d $SERVER0 --sport ntp -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A INPUT -p udp -s $SERVER1 --sport ntp -m state --state ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p udp -d $SERVER1 --sport ntp -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A INPUT -p udp -s $SERVER2 --sport ntp -m state --state ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p udp -d $SERVER2 --sport ntp -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A INPUT -p udp -s $SERVER3 --sport ntp -m state --state ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p udp -d $SERVER3 --sport ntp -m state --state NEW,ESTABLISHED -j ACCEPT

  sudo systemctl restart ntp.service
  echo -e "${Underline}NTP Setup ${Blink}Complete${Off}${FgLtBlue}!!!"
  echo -e " "
  else
  echo -e "${Underline}NTP Setup ${Blink}Aborted${Off}${FgLtBlue}!!!"
  fi
else
  echo -e "${Underline}NTP Setup ${Blink}Aborted${Off}${FgLtBlue}!!!"
fi
}


function doamasternode() {

clear
preflightchecks
download_node
configure_systemd
setup_node
}

function justwallet() {
clear
JUSTWALLET=true
preflightchecks
download_node
get_ip
create_wallet_config
wallet_replace
enable_firewall
startdaemon
important_information



}

function preflightchecks() {
stopdaemon
purgeOldInstallation
checks
memorycheck
}

function setup_node() {
get_ip
create_key
create_config
wallet_replace
enable_firewall
startdaemon
important_information
}


##### Main #####
mainmenu2


