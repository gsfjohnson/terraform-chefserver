#!/bin/sh

/usr/bin/hostnamectl set-hostname ${hostname}.${domainname}

yum -y install https://packages.chef.io/stable/el/7/chef-server-core-12.6.0-1.el7.x86_64.rpm >/root/chef-install.log

chef-server-ctl reconfigure >>/root/chef-install.log
