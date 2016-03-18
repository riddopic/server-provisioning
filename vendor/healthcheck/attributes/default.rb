# encoding: UTF-8

# default user
default['users'] = []

# add user to docker group so no sudo rights are required to execute docker
default['docker']['group_members'] =  []
# override the DOCKER_OPTS set from docker cookbook
default['docker']['host'] = ['127.0.0.1:2375', 'unix:///var/run/docker.sock']
# disable startup scripts for containers
default['docker']['container_init_type'] = false

default['ntp']['servers'] = []

