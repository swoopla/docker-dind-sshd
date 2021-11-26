#!/usr/bin/env ash

# set docker settings
echo "export DOCKER_HOST='${DOCKER_HOST}'" >> /etc/profile

# deploy docker-client-config ( docker registry login)
if [ ! -z "${DOCKER_CLIENT_CONFIG_JSON}" ]; then
	if [ ! -d /root/.docker ]; then 
		mkdir /root/.docker
	fi
    echo ${DOCKER_CLIENT_CONFIG_JSON} > /root/.docker/config.json
fi

#prepare run dir
if [ ! -d "/var/run/sshd" ]; then
  mkdir -p /var/run/sshd
fi

# deploy authorized_keys
if [ ! -z "${AUTHORIZED_KEYS}" ]; then
	if [ ! -d /root/.ssh ]; then
		mkdir /root/.ssh
	fi
    echo "${AUTHORIZED_KEYS//$'\n'/\n}" > /root/.ssh/authorized_keys
	chmod 700 /root/.ssh
	chmod 600 /root/.ssh/authorized_keys
fi

# show configuration
cat /etc/ssh/sshd_config

# generate new host key files
ssh-keygen -A

# run sshds
exec /usr/sbin/sshd -D -e "$@"