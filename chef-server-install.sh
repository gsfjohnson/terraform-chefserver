#!/bin/bash

hostnamectl set-hostname ${fqdn}

yum -y git

#git clone https://github.com/certbot/certbot
#cd certbot
#./certbot-auto -n -v >>/root/chef-install.log

yum -y install https://packages.chef.io/stable/el/7/chef-server-core-12.6.0-1.el7.x86_64.rpm >>/root/chef-install.log

chef-server-ctl reconfigure >>/root/chef-install.log
