# Infrastructure as Code with Ansible
## Infrastructure as Code
### What is Infrastructure as Code?
Infrastructure as Code (IaC) is a method to provision and manage IT infrastucture through use of machine-readable definition files (source code), rather than through operating procedures and manual processes.

### What are the benefits of Infrastructure as Code?
- Speed and simplicity
- Configuration consistency
- Minimisation of risk
- Increased efficiency
- Cost savings

### Aspects of Infrastructure as Code
#### Configuration Management
Configuration Management (CM) tools are responsible for provisioning and maintaining the state of your systems. Examples of tools that can be used for CM include:
- Chef
- Puppet
- Ansible
#### Orchestration
After the templates for all parts of the system are created, orchestration tools and scripts are used to talk to the cloud and pull them together into an architecture structure. Example tools for orchestration include:
- Cloud Formation (AWS)
- Ansible
- Terraform

## Ansible
### What is Ansible?
Ansible is an IT automation engine that automates cloud provisioning, configuration management, application deployment, and intra-service orchestration.

### What are the benefits of Ansible?
- Simple (uses YAML so is readable)
- Agentless (lightweight on agent nodes and doesn't need to install on agent nodes)
- Secure (uses SSH to connect to other machines)

### Adhoc commands
- `ssh vagrant@ip` SSH into another vagrant machine using IP
- `sudo nano provision.sh`
	```
	sudo apt-get update -y
	sudo apt-get install software-properties-common -y
	sudo apt-add-repository ppa:ansible/ansible -y
	sudo apt-get update -y
	sudo apt-get install ansible -y
	```

- `ansible all -m ping` ping all machines
- `sudo apt install tree` install tree (controller)
- `tree` display tree (in ansible directory)
- `sudo nano hosts` to update hosts file
	- `[web] 192.168.33.10 ansible_connection=ssh ansible_ssh_user=vagrant ansible_ssh_pass=vagrant`
	- `[db] 192.168.33.11 ansible_connection=ssh ansible_ssh_user=vagrant ansible_ssh_pass=vagrant`
- `ping 192.168.33.10` ping IP
- `ansible all -m ping` ping all
- `ansible web -a "uname -a"` check name for web machine
- `ansible web -a "date"` check the date for the web machine
- `ansible web -a "free -m"`
- `ansible web -m shell -a "ls -a"` list files in web
- `ansible web -m shell -a "uptime"` display uptime for web machine
- `ansible all -a "sudo apt-get update -y"` to update all machines
- `ansible all -a "sudo apt-get upgrade -y"` to upgrade all machines

### Playbooks
- `sudo nano install_nginx.yml` to create YAML file
```
---
- hosts: web
# host is to define the name your host machine or you could do all if you would like to run the same task in all the servers

  gather_facts: yes
# gathering facts before performing any tasks

  become: true
# become is used to get root permission to perform any tasks that require admin access

  tasks:
# tasks area executed in order, one at a time, against all servers matched by the host
# every task should a name, which is included in the output from running in the playbook
# The goal of each task is to execute a module, with very specific arguments

# In this task we wouldl like to install Nginx on our web server
  - name: Installing Nginx
    apt: pkg=nginx state=present
```
- `ansible-playbook rds_prod.yml  --syntax-check` to check syntax
- `ansible-playbook install_nginx.yml` to run YAML file

### Ansible Vault
- `sudo apt-add-repository --yes --update ppa:ansible/ansible`
- `sudo apt install python3-pip -y` install pip
- `pip3 install boto boto3` install boto3
- `mkdir group_vars`, `cd group_vars`, `mkdir all`, `cd all`
- `sudo ansible-vault create pass.yml` to create vault for keys
	- `aws_access_key: ACCESSKEY`
	- `aws_secret_key: SECRETKEY`
	- `esc :wq enter`

# Ansible & AWS Task
## Create an EC2 instance using Ansible
### Set up a controller EC2
- Start up a public EC2 instance
- SSH into the new controller instance
- `sudo apt install python`
- `sudo apt-get install software-properties-common`
- `sudo apt-add-repository ppa:ansible/ansible`
- `sudo apt-get update -y`
- `sudo apt install python-pip`
- `pip install boto boto3`
- `sudo apt-get install ansible`
- `ansible --version` check correct version (2.9.21)

### Ansible Vault & EC2 Instances
- `mkdir -p AWS_Ansible/group_vars/all/`
- `cd AWS_Ansible`
- Create playbook.yml
  - `touch playbook.yml` to create new playbook `sudo nano playbook.yml` to later edit
  - `scp -i ~/.ssh/eng84devops.pem -r playbook.yml ubuntu@ip:~/AWS_Ansible/playbook.yml` to copy playbook.yml
- `ansible-vault create group_vars/all/pass.yml` create vault
	- `aws_access_key: ACCESSKEY`
  - `aws_secret_key: SECRETKEY`
  - `esc :wq enter`
- `ansible-playbook playbook.yml --ask-vault-pass` to provision instances
- `ansible-playbook playbook.yml --ask-vault-pass --tags create_ec2` to create EC2 instance

## Set up 2 tier architecture
### Connect EC2 instances to controller
- `scp -i ~/.ssh/eng84devops.pem -r eng84devops.pem ubuntu@ip:~/.ssh/eng84devops.pem` secure copy keys to controller
- `chmod 400 .ssh` to secure keys to only be readable by the owner
- Ensure security groups for EC2 instances allow controller to access them
- Test EC2 instance and keys using SSH
  - `sudo ssh -i ".ssh/eng84devops.pem" ubuntu@private_ip` to ssh into a machine
- Update hosts file to use python and add EC2 connection
```
[local]
localhost ansible_python_interpreter=/usr/bin/python3

[web]
web_private_ip ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/eng84devops.pem

[db]
db_private_ip ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/eng84devops.pem
```
- `sudo ansible web -a "command" --ask-vault-pass` will now run a specified command on the web EC2

### Add content & run provisions
- `scp -i ~/.ssh/eng84devops.pem -r app/ ubuntu@public_ip:~/app/` to copy app info to controller
- `sudo scp -i ~/.ssh/eng84devops.pem -r app/ ubuntu@private_ip:~/app/` to copy app info to EC2
- `scp -i ~/.ssh/eng84devops.pem -r provision.sh ubuntu@public_ip:~/provision.sh` copy both provisions to controller
- `sudo scp -i ~/.ssh/eng84devops.pem -r provision.sh ubuntu@private_ip:~/provision.sh` copy provisions to relevant EC2
- `sudo ansible all -a "ls" --ask-vault-pass` to check files in EC2
- Convert dos2unix for both files
  - `sudo ansible web -a "wget "http://ftp.de.debian.org/debian/pool/main/d/dos2unix/dos2unix_6.0.4-1_amd64.deb"" --ask-vault-pass`
  - `sudo ansible web -a "sudo dpkg -i dos2unix_6.0.4-1_amd64.deb" --ask-vault-pass`
  - `sudo ansible web -a "dos2unix provision.sh" --ask-vault-pass`
- `sudo ansible web -a "./provision.sh" --ask-vault-pass`




- `sudo ssh -i "eng84devops.pem" ubuntu@private_ip` to check provisions correctly copied
- `chmod +x provision.sh` change permissions on provision file
- `./provision.sh` run the provision file on host machine to setup app

#### Ansible
- `ansible --ask-vault-pass web -a "./provision.sh"` to run provision.sh on web after copying




### Set up provision files on controller
- `sudo nano app_provision.sh` to create app provision
```
#!/bin/bash

# Update the sources list
sudo apt-get update -y

# upgrade any packages available
sudo apt-get upgrade -y

# install nginx
sudo apt-get install nginx -y

# install npm
apt-get install npm -y

# install git
sudo apt-get install git -y

# install nodejs
sudo apt-get install python-software-properties
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install nodejs -y

# install pm2
sudo npm install pm2 -g

# environment
npm install /home/ubuntu/app/app

# generate seed
nodejs /home/ubuntu/app/app/seeds/seed.js

sudo echo "server {
  listen 80;
  
  server_name _;
  
  location / {
    proxy_pass http://localhost:3000;
      proxy_http_version 1.1;
      proxy_set_header Upgrade \$http_upgrade;
      proxy_set_header Connection 'upgrade';
      proxy_set_header Host \$host;
      proxy_cache_bypass \$http_upgrade;
    }
}" | sudo tee /etc/nginx/sites-available/default
```
- `sudo nano db_provision.sh` to create database provision
```
#!/bin/bash

# Update sources list
sudo apt-get update -y

# Upgrade any packages
sudo apt-get upgrade -y

# mogo
wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add -
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
sudo apt-get update
sudo apt-get install -y mongodb-org=3.2.20 mongodb-org-server=3.2.20 mongodb-org-shell=3.2.20 mongodb-org-mongos=3.2.20 mongodb-org-tools=3.2.20

sudo mkdir -p /data/db
sudo chown -R mongodb:mongodb /var/lib/mongodb
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
sudo systemctl enable mongod
sudo service mongod start
```