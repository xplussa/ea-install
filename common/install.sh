#!/bin/bash

copyStartFile () {
	if [ ! -d "../instances/$1/" ]; then
		mkdir ../instances/$1
		cp -a ./deploy-example/. ../instances/$1/
		sed -i "s/<env_name>/$1/g" ../instances/$1/.env
		sed -i "s/<env_name>/$1/g" ../instances/$1/docker-compose.yml
		echo "Instance \"$1\" create!"
	else 
		echo "Instance \"$1\" exist!"
	fi
}

POSITIONAL=()
while [[ $# -gt 0 ]] 
do
key="$1"
case $key in
	-c|--create)
		if [ $2 ]; then
		echo $2
			copyStartFile $2
		else
			echo "Name required!"
		fi
		shift 
    ;;
	*)   
		shift 

esac
done
set -- "${POSITIONAL[@]}" 
echo "$env_proxy_port $env_ip $env_adm_port $env_proxy_port"

