#!/bin/bash

docker_registry_token=variable=`cat ../../common/token.key`

start_env () {
	echo "START"
	name=${PWD##*/}
	ENV_NAME=$name /usr/local/bin/docker-compose -f docker-compose.yml -f ../../common/common.yml up -d $1 >> ./cron.log 
}

stop_env () {
	echo "STOP"
	name=${PWD##*/}		
	ENV_NAME=$name /usr/local/bin/docker-compose -f docker-compose.yml -f ../../common/common.yml stop $1 >> ./cron.log
}

restart_env () {
	stop_env $1
	start_env $1
}

update_env () {
	docker_login $1
	docker_pull 
	start_env
}

status_env () {
	ENV_NAME=$name /usr/local/bin/docker-compose -f docker-compose.yml -f ../../common/common.yml ps $1
}

log_env () {
	ENV_NAME=$name /usr/local/bin/docker-compose -f docker-compose.yml -f ../../common/common.yml logs  -f $1
}

exec_env () {
	ENV_NAME=$name /usr/local/bin/docker-compose -f docker-compose.yml -f ../../common/common.yml logs  -f $1
}

install_env () {
	echo "INSTALL"
	name=${PWD##*/}	
	docker_login $1
	docker_pull
	docker network create ea-net || echo "ea-net exist"
	docker volume inspect ea-data-$name || docker volume create --name=ea-data-$name
	start_env
}

docker_login () {
	echo "LOGIN TO DOCKER REGISTRY"
	docker login xpluseaprod.azurecr.io -u xpluseaprod -p $1 >> ./cron.log
}

docker_pull () {
	/usr/local/bin/docker-compose -f docker-compose.yml -f ../../common/common.yml  pull >> ./cron.log
}

help_f () {
echo "EA-SERVER Manager 0.1"
echo $"Usage: $0 --start api worker"
echo " -u --up --start *conteners_name     -UP all conteners or *specyfic contener"
echo " -s --stop *conteners_name           -STOP all conteners or *specyfic contener"
echo " -r --restart *conteners_name        -RESTART all conteners or *specyfic contener"
echo " -a --update                         -UPDATE all conteners"
echo " -l --log *conteners_name            -show LOGS all conteners or *specyfic contener"
echo " -t --status *conteners_name         -show STATUS all conteners or *specyfic contener"
echo " -i --install                        -create a specyfic docker-volume, network. Pull new image and run all."
echo " -h --help                           -show this message"
}



POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -r|--restart)
		restart_env $2
		shift # past argument
		shift # past value
    ;;
    -u|--up|--start)
		start_env $2
		shift # past argument
		shift # past value
    ;;
    -s|--stop)
		stop_env $2
		shift # past argument
		shift # past value
    ;;
	-a|--update)
		update_env $docker_registry_token
		shift # past argument
		shift # past value
    ;;
	-i|--install)
		install_env $docker_registry_token
		shift # past argument
		shift # past value
    ;;
	-l|--log)
		log_env $2
		shift # past argument
		shift # past value
    ;;
	-t|--status)
		status_env $2
		shift # past argument
		shift # past value
    ;;
	-h|--help)
		help_f
		shift # past argument
		shift # past value
    ;;
    -d|--default)
		echo "test"
		update_env $docker_registry_token
		shift # past value
    ;;
    *)    # unknown option
	echo $"Usage: $0 {start|stop|restart|update|install}"
		shift # past argument

esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


