#!/usr/bin/bash

# sudo yum -y update

#Ansible
sudo yum -y install epel-release
sudo yum -y install ansible

# Configuring Ansible
sudo touch /home/vagrant/hosts.txt
sudo cat <<EOF | sudo tee -a /home/vagrant/hosts.txt
controller ansible_connection=local
[loadBalancer]
localhost ansible_connection=local
loadBalancer ansible_ssh_host=192.168.56.10 ansible_user=vagrant ansible_ssh_private_key_file=/home/vagrant/.ssh/192.168.56.10.pem
EOF

# Chainge Permitions for keys r-x------
sudo chmod -R 500 /home/vagrant/.ssh/
# Allow connecting without checking host
sudo cat <<EOF | sudo tee -a /etc/ansible/ansible.cfg
[defaults]
host_key_checking = false
inventory = /home/vagrant/hosts.txt

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes
EOF

sudo ansible-playbook playbook.yml

# Configuring haproxy
sudo touch /home/vagrant/templates/haproxy.cfg.j2
sudo cat <<EOF | sudo tee -a /home/vagrant/templates/haproxy.cfg.j2
global
    
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000
frontend  main 192.168.56.10:80
    acl url_static       path_beg       -i /static /images /javascript /stylesheets
    acl url_static       path_end       -i .jpg .gif .png .css .js
    use_backend static          if url_static
    default_backend             app
backend static
    balance     roundrobin
    server      static 127.0.0.1:4331 check
backend app
    balance     roundrobin
    server  app1 192.168.56.11:80 check
    server  app2 192.168.56.12:80 check
EOF

