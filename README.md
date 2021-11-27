# dind-sshd

## About

A DockerInDocker [docker:dind](https://hub.docker.com/_/docker?tab=tags) image with SSHD installed. This image can be used by RUNDECK container, ANSIBLE container or other program based on SSH protocol.

## Why root user on image ?

["The docker group grants privileges equivalent to the root user."](https://docs.docker.com/engine/install/linux-postinstall/)

## Environment Options

- `DOCKER_HOST` Daemon socket to connect to. (localhost by default)
- `AUTHORIZED_KEYS` Authorized key for *root* user
- `DOCKER_CLIENT_CONFIG_JSON` directive to add into _/root/.docker/config.json_ file (not present by default)

## Usage

* Can be use with ansible or rundeck container
* Schedule Database backup
* Create / Destroy / Restart a container
* Run a command in a container and get the result

## Usage Example with Rundeck

```yaml
version: '3.8'

# container restart policy
x-restart: &restart
  restart: always

# container logging policy
x-logging: &logging
  logging:
    driver: "json-file"
    options:
      max-file: "5"
      max-size: "10m"

services:
  ctl:
    image: swoopla/dnd-sshd:latest
    expose:
      - 22
    environment:
      DOCKER_HOST: "tcp://socket-proxy:2375"
      AUTHORIZED_KEYS: "ssh-rsa AAAAB3N...nIGWJ="
    networks:
      - dockersocket4treafik
      - br-rundeck
    <<: *logging
    <<: *restart

  socket-proxy:
    image: tecnativa/docker-socket-proxy
    container_name: socket-proxy
    restart: unless-stopped
    expose:
      - 2375
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      CONTAINERS: 1
    networks:
      - dockersocket4treafik
    <<: *logging
    <<: *restart
  
  rundeck:
    image: rundeck/rundeck:3.4.3
    volumes:
      - ${REALPATH:-.}/rundeck_data:/home/rundeck/server/data:rw
      - ${REALPATH:-.}/rundeck_.ssh/:/home/rundeck/.ssh/:rw
    ports:
      - 4440:4440
    networks:
      - br-rundeck
    <<: *logging
    <<: *restart

networks:
  br-rundeck:
    driver: bridge
  dockersocket4treafik:
    driver: bridge
```

### How it's work

```
  rundeck:
    volumes:
      - ${REALPATH:-.}/rundeck_.ssh/:/home/rundeck/.ssh/:rw
```
Mount *.ssh* folder with 
*  _id_rsa.pub_ and _id.rsa_
* *config* file for SSH client option:
```
Host *
  StrictHostKeyChecking no
```

In rundeck application, create a job who run localy with *ssh ctl 'docker ps'*. That's all !

### Push image on Docker HUB

if you add another folder like this :

```
  ctl:
    volumes:
      - ${REALPATH:-.}/ctl_build/:/build:rw
    environment:
      DOCKER_CLIENT_CONFIG_JSON: '{\n "auths": {\n  "https://index.docker.io/v1/": {\n   "auth": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"\n		}\n	}\n}'      
```
And you write a job who build a *Dockerfile* in _/build/_, you can *push* it on docker hub.