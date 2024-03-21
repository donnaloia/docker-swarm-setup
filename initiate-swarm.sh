#!/bin/bash

# Get Droplet's private IP
# private_ip=$(hostname -I | cut -d " " -f 3)

# # Start Swarm
# docker swarm init \
# --listen-addr $private_ip \
# --advertise-addr $private_ip


docker swarm init 
swarm_token = $(docker swarm join-token -q worker >> swarm-token.sh && cat swarm-token.sh)

#docker node inspect --format '{{ .ManagerStatus.Addr }}' manager1
pub_ip = $(dig +short myip.opendns.com @resolver1.opendns.com)

echo "docker swarm join --token $swarm_token $pub_ip" >> /home/ec2-user/join-swarm.sh

# construct the following command into a shell script using the values above
# docker swarm join --token SWMTKN-1-5w1chizpkdrb9uhl63sgb0ii87zix0gkv54bd0ux8tjjp1fhi2-8150gchdaqft7srwe7uqoomyu 
# 18.0.1.209:2377