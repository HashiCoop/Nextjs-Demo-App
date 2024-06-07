#!/bin/bash

sudo apt-get update
sudo apt-get -y install ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install docker
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add hashicorp key and install vault, consul, and envconsul
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get -y install vault consul boundary awscli

# ### Setup persistent DNS binding to consul
# echo iptables-persistent iptables-persistent/autosave_v4 boolean false | sudo debconf-set-selections
# echo iptables-persistent iptables-persistent/autosave_v6 boolean false | sudo debconf-set-selections
# DEBIAN_FRONTEND=noninteractive apt install -yq iptables-persistent openresolv jq

# echo '
# [Resolve]
# DNS=127.0.0.1 
# Domains=~consul
# ' > /etc/systemd/resolved.conf

# mkdir -p /etc/resolvconf/resolv.conf.d/
# touch /etc/resolvconf/resolv.conf.d/head
# echo '
# search consul
# nameserver 127.0.0.1
# ' >> /etc/resolvconf/resolv.conf.d/head

# resolvconf -u

# iptables -t nat -A OUTPUT -d localhost -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
# iptables -t nat -A OUTPUT -d localhost -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600
# netfilter-persistent save

# chown -R consul:consul /opt/consul

# ### Set default consul client config
# echo '
# data_dir = "/opt/consul"
# client_addr = "0.0.0.0"
# advertise_addr = "'$PRIVATE_IP'"
# retry_join = ["provider=aws tag_key=consulAutoJoin tag_value=server"]
# leave_on_terminate = true
# enable_local_script_checks = true
# ' > /etc/consul.d/consul.hcl

# ### Export default vars
# echo '
# export PRIVATE_IP=$(curl $PRIVATE_IP_METADATA_URL)
# export PUBLIC_IP=$(curl $PUBLIC_IP_METADATA_URL)
# export VAULT_ADDR="http://$PRIVATE_IP:8200"
# export VAULT_SKIP_VERIFY=true
# ' >> /etc/profile