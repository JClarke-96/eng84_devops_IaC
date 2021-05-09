#!/bin/bash

# install python
sudo apt install python

# setup for pip
sudo apt-get install software-properties-common
sudo apt-add-repository ppa:ansible/ansible

# Update the sources list
sudo apt-get update -y

# upgrade any packages available
sudo apt-get upgrade -y

# pip and boto3
sudo apt install python-pip
pip install boto boto3

# install ansible
sudo apt-get install ansible
ansible --version
-