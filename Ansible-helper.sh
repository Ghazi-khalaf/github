# Ansible helper
yum update -y
yum install -y epel-release
yum install -y  python3
alternatives --set python /usr/bin/python3
yum install -y  python3-argcomplete
yum install ansible -y
activate-global-python-argcomplete 
ansible --version

222222222222222222222222222222222222

ghazi 


ansible all --list
# preapre the connection with target node 
ssh-keygen 
ls /root/.ssh
ssh-copy-id root@140.82.30.73
# test the host if ansible can ping 
ansible -m ping all
ansible -a "uptime" all
# the power permission from best to lowest 
# location in $ANSIBLE_CONFIG
# ./ansible.cfg
# user home/ansible.cfg
# /etc/ansible/ansible.cfg


# to get ansible.cfg examples 
ansible-config init --disabled > ansible.cfg
ansible-config init --disabled -t all > ansible.cfg

############## ad-hoc ##############
# ad-hoc command in ansible used to run one time task such as reboot al the host using ad-hoc no need to make playbook for that mayber we could use it for testing before using playbook
# exaple of ad-hoc reboot
ansible webservers -a "/sbin/reboot"

# Ansible by default run 5 proceses in same time if we have like 100 server we cloud spicify the number of task we need ansible to run it 
ansible webservers -a "/sbin/reboot" -f 10 #or more 
ansible webservers -a "/sbin/reboot" -u user1 # to run the command with defreent user
ansible webservers -a "/sbin/reboot" -u user1 --become #to run the command with sudo privilage

# Manage the files and directory
ansible webservers -m copy -a "src=/etc/hosts dest=./hosts"
# test sending file from controller to target01 server
ansible target01 -m copy -a "src=/root/ansible.cfg dest=./ansible_controller"

# to manage file permission in target 
ansible target01 -m file -a "dest=/home/db.txt mode=600" # example
ansible target01.ringopbx.com -m file -a "path=/root/ghaziroot.log state=touch mode=777" # this will create a file with 777 permission
ansible target01.ringopbx.com -m copy -a "dest=/root/ghaziroot.log content="touch" force=no mode=777"  # force=no means don't change the file if already exsit im adding touch in the file like this 
ansible target01.ringopbx.com -m file -a "dest=/root/ghaziroot.log mode=777"  # change file permission
ansible target01.ringopbx.com -m file -a "dest=/root/ghaziroot.log mode=777 owner=root group=root" -b -k # will change the user and group owner of the target file on target machine
ansible target01.ringopbx.com -m file -a "path=/root/newdir mode=755 state=directory" #create directory
ansible target01.ringopbx.com -m file -a "path=/root/newdir mode=755 state=absent"  # to delete directory

# install delete the packges 
ansible target01.ringo* -m yum -a "name=httpd state=installed" -b -k # httpd packge to be downloaded 
ansible target01.ringo* -m yum -a "name=httpd state=latest" -b -k  # to install latest httpd version
ansible target01.ringo* -m yum -a "list=installed" -b -k 
ansible 172.27.100.18* -m yum -a "name=htop state=absent" -b -k

# Manage the services 
ansible 172.27.100.18* -m yum -a "name=htop state=absent" -b -k
ansible 172.27.100.18** -m yum -a "name=httpd state=latest" -b -k
ansible 172.27.100.18* -m service -a "name=httpd state=started" -b -K
ansible 172.27.100.18* -m service -a "name=httpd state=restarted"
ansible 172.27.100.18* -m service -a "name=httpd state=stopped"
ansible 172.27.100.18* -m service -a "name=httpd enabled=yes"
ansible 172.27.100.18* -m service -a "name=httpd disabled=yes"
ansible 172.27.100.18* -m service -a "name=httpd enabled=yes" --check


ansible 172.27.100.18* -m shell -a "systemctl status httpd"
ansible 172.27.100.18* -a '/sbin/reboot'
ansible -m ping all

# Manging Users

ansible 172.27.100.18* -m user -a 'user=osboxes state=present home=/home/osboxes shell=/bin/bash'
ansible 172.27.100.18* -m user -a "user=osboxes group=wheel" #cchange group of user

#Gather data
ansible 172.27.100.18* -m setup # Like this i will get all the details about the data 
ansible 172.27.100.18* -m setup -a 'gather_subset=network'

# to access ansible console 
ansible-console -b -K
root@all (2)[f:5]# cd allservers
root@allservers (2)[f:5]# shell cat /etc/hosts

# inventory
ansible-inventory --list
ansible-inventory --list --output inventory.json

#in VIM
:set number 

# make playbook
vim apache.yml
---
- name: Apche server installed
  hosts: allservers
  become: yes
  tasks:
        - name: latest apche version installed
          yum:
                name: httpd
                state: latest
        - name: Apache enable and running
          service:
                name: httpd
                enabled: true
                state: started

#check
ansible-playbook --syntax-check apache.yml
#result means ok
playbook: apache.yml

ansible-playbook apache.yml -b

#################################
# playbook 
#example
tasks:
    - name: copy http.conf
      copy:
        src: httpd.conf
        dest: /etc/httpd/conf/http.conf
    -name: restart apach
      service:
        name: httpd
        state: restarted
########################################
#Create structured configuration
######
cd /var/ansible-files/
yum install -y tree
vi hosts
mkdir group_vars
mkdir -p roles/{base,webservers,dbservers}/{handlers,tasks,templates}
tree
############################
# Roles
[root@ansible-controler ansible-files]# tree
.
├── apache.yml
├── group_vars
├── hosts
├── roles
│   ├── base
│   │   ├── handlers
│   │   ├── tasks
│   │   │   └── main.yml
│   │   └── templates
│   ├── dbservers
│   │   ├── handlers
│   │   ├── tasks
│   │   └── templates
│   └── webservers
│       ├── handlers
│       ├── tasks
│       └── templates
└── site.yml

# so here we have a well stracture contain base webserver and more role for each componant
# for example base contain handler tasks templete and more for all nodes for basic configuration

#########################################################
 cat site.yml
---
# This playbook deploy all site configuge

- name: apply base configuration to all hosts
  hosts: all
  remote_user: root

  roles:
  - base
#########################################################
 cat roles/base/tasks/main.yml
---
# this playbook contain base place for all node

- name: install firewalld
  yum: name=firewalld state=present


- name: start firewalld service
  service: name=firewalld state=started enabled=yes
#########################################################
ansible-playbook -i hosts site.yml 

 pwd
/var/ansible-files/roles/webservers/tasks

#########################################################
 cat main.yml
---
- include: install_apache.yml
#########################################################
 cat install_apache.yml
---
# Install apache
- name: Install apache
  yum: name=httpd state=present


- name: Apache service state
  service: name=httpd state=started enabled=yes

- name: Start firewalld
  service: name=firewalld state=started enabled=yes

- name: Add firewall rule for apache
  firewalld: port=80/tcp permanent=true state=enabled immediate=yes
#########################################################
vim /var/ansible-files/site.yml

#########################################################
---
# This playbook deploy all site configuge

- name: apply base configuration to all hosts
  hosts: all
  remote_user: root

  roles:
  - base

- name: Configure Webservers
  host: webservers
  remote_user: root

  roles:
   - webservers
#########################################################
 ansible-playbook -i hosts site.yml
#PLAY RECAP *****************************************************************************************************
#target01.lab               : ok=8    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
#target02.lab               : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

# if we need to change the default path for hosts 
############
vim /etc/ansible/ansible.cfg
[defaults]
inventory = /var/ansible-files/hosts
############
ansible webservers -m setup
## to filter network device 
ansible webservers -m setup -a "filter=*enp0s3"
#########################################################
vim ansible-facts.yml
cat ansible-facts.yml
---
- hosts: webservers

  tasks:
    - name: Ansible Facts
      debug:
        msg: "{{ ansible_facts['enp0s3']['ipv4']['address'] }}"
#########################################################
ansible-playbook -i hosts ansible-facts.yml
# use the variable file in playbook
vim /var/ansible-files/group_vars/webservers

# Variable file
cat group_vars/webservers
#########################################################
---
# Variables for webservers group
httpd_port: 80
#########################################################
cd roles/webservers/tasks/
vim /var/ansible-files/roles/webservers/tasks/install_apache.yml
# here we use variable file to difine the port of httpd
#########################################################
---
# Install apache
- name: Install apache
  yum: name=httpd state=present


- name: Apache service state
  service: name=httpd state=started enabled=yes

- name: Start firewalld
  service: name=firewalld state=started enabled=yes

- name: Add firewall rule for apache
#  firewalld: port=80/tcp permanent=true state=enabled immediate=yes
  firewalld: port={{ httpd_port }}/tcp permanent=true state=enabled immediate=yes
#########################################################
ansible-playbook -i hosts  site.yml



# Looping with lists

 vim /var/ansible-files/roles/base/tasks/main.yml
#########################################################
---
# this playbook contain base place for all node

- name: install base packages
  yum: "name={{ item }} state=present"
  loop: "{{ base_packages}}"

- name: start firewalld service
  service: name=firewalld state=started enabled=yes
#########################################################
cd /var/ansible-files/group_vars/
vim /var/ansible-files/group_vars/all
#########################################################
---
# Variables for the all groups
base_packages:
  - python3-libselinux
  - python3-libsemanage
  - htop
  - firewalld
#########################################################
cd ..
 ansible-playbook -i hosts site.yml
#############
mkdir -p roles/{base,baseEL8,webservers,dbservers}/{handlers,tasks,templates,files,vars,default,meta}

https://galaxy.ansible.com/ui/repo/published/mafalb/apache/
ansible-galaxy collection install mafalb.apache
ansible-playbook playbook.yml --start-at-task "Start httpd service"
sudo hostnamectl set-hostname target01.lab

# here we are talking about larg and chaning type infrstracture 
# if we have changingble infrastracture we could use Dynamic inventory 
# it's recommended to give a good name to inventory files
vultr.yml for example
# use pluge
ansible -i vultr.yml site.yml
ansible -i vultr.yml site.yml --graph
# to show availabe plugen
ansible-doc -t inventory -l
ansible-doc -t inventory vultr

## to change the number or task runing same time we should changes the forks as below
# under defaults
vim /etc/ansible/ansible.cfg
[defaults]
forks = 30

# for example how to set the number in playbook file ( this will efect the host in that file only )
---
- name: install base packages
  hosts: webservers
  serial:
    - 1
    - 4
    - 5
#etc
# here the -1 will run one by one for the first task and 4 will run 4 toghther for the secound task etc\

# Performance tuning Ansible and optimize for Example Fact Gathering
---
- name: install base packages
  hosts: webservers
  gather_facts: no
# or you can use 
---
- name: install base packages
  hosts: webservers
  gather_facts: False
  pre_tasks:
    - setup:
      gather_subset:
        - '!all'
#etc

# save the output log
ansible-playbook -i hosts  site.yml | tee output.log

# if we need to save the log all the time we can have the below edit 
vim /etc/ansible/ansible.cfg
[defaults]
log_path = /var/ansible-files/ansible-logs/ansible.log

# Monitor playbook
# we can add the below uner the task
check_mode: yes

# Ansible Vult
# to secure password token and more
# understand Ansible role structure
roles/
    common/               # this hierarchy represents a "role"
        tasks/            #
            main.yml      #  <-- tasks file can include smaller files if warranted
        handlers/         #
            main.yml      #  <-- handlers file
        templates/        #  <-- files for use with the template resource
            ntp.conf.j2   #  <------- templates end in .j2
        files/            #
            bar.txt       #  <-- files for use with the copy resource
            foo.sh        #  <-- script files for use with the script resource
        vars/             #
            main.yml      #  <-- variables associated with this role
        defaults/         #
            main.yml      #  <-- default lower priority variables for this role
        meta/             #
            main.yml      #  <-- role dependencies
        library/          # roles can also include custom modules
        module_utils/     # roles can also include custom module_utils
        lookup_plugins/   # or other types of plugins, like lookup in this case

    webtier/              # same kind of structure as "common" was above, done for the webtier role
    monitoring/           # ""
    fooapp/               # ""

#################
    tasks/main.yml        - the main list of tasks that the role executes.
    handlers/main.yml     - handlers, which may be used within or outside this role.
    library/my_module.py  - modules, which may be used within this role (see Embedding modules and plugins in roles for more information).
    defaults/main.yml     - default variables for the role (see Using Variables for more information). These variables have the lowest priority of any variables available and can be easily overridden by any other variable, including inventory variables.
    vars/main.yml         - other variables for the role (see Using Variables for more information).
    files/main.yml        - files that the role deploys.
    templates/main.yml    - templates that the role deploys.
    meta/main.yml         - metadata for the role, including role dependencies and optional Galaxy metadata such as platforms supported.

# roles/example/tasks/main.yml
- name: Install the correct web server for RHEL
  import_tasks: redhat.yml
  when: ansible_facts['os_family']|lower == 'redhat'

- name: Install the correct web server for Debian
  import_tasks: debian.yml
  when: ansible_facts['os_family']|lower == 'debian'

# roles/example/tasks/redhat.yml
- name: Install web server
  ansible.builtin.yum:
    name: "httpd"
    state: present

# roles/example/tasks/debian.yml
- name: Install web server
  ansible.builtin.apt:
    name: "apache2"
    state: present
###### crontab using Ansible
roles/crontab/tasks/main.yml
---
- name: Add cron job
  cron:
    name: "My cron job"
    minute: "*/5"
    job: "/path/to/your/command"
    state: present

roles/crontab/defaults/main.yml:

---
- name: Manage crontab
  hosts: your_target_hosts
  roles:
    - crontab


######## ringo ansible 05/02/2024
cat daily_maintenance.yml
---
# All Daily Operation On All PBX servers Ghazi
- name: Update FreePBX modules | Reload | Trust the hosts File for all Freepbx Ghazi
  hosts: pbx
  remote_user: root

  roles:
    - pbxs

- name: Run Base System Maintinance on all server yum Ghazi
  hosts: all
  remote_user: root

  roles:
    - maintenance
########################
 cat roles/maintenance/tasks/main.yml
---
- name: System Packages Update for all servers Ghazi
  yum:
    name: '*'
    state: latest

########################
cat roles/pbxs/tasks/main.yml
---
- name: Update FreePBX server modules Ghazi
  shell: /usr/sbin/fwconsole ma upgradeall

- name: Reload FreePBX fwconsole Ghazi
  shell: /usr/sbin/fwconsole reload

- name: Get IPs and DNS names from hosts file
  set_fact:
    hosts_content: "{{ lookup('file', '/var/ansible-master/hosts').split('\n') }}"

- name: Extract IPs and DNS names
  set_fact:
    ips_and_dns: "{{ hosts_content | select('match', '^(?!#|.*[\\[\\]])\\S') | list }}"

- name: Add All Ringo Prod & Dev servers for each freepbx Servers
  command: fwconsole firewall trust "{{ item }}"
  loop: "{{ ips_and_dns }}"
########################
cat roles/new_almalinux/tasks/main.yml
---
- name: install listed packages
  yum: "name={{ item }} state=present"
  loop: "{{ base_packages}}"
  notify:
    - Clean Yum Cache
    - Copy Fail2Ban configuration file
    - start fail2ban
    - enable fail2ban
    - reload fail2ban







- name: Synchronize script files
      synchronize:
        src: /var/ansible-master/roles/pbxs/files/production/ 
        dest: /var/script/production/ 
        recursive: yes



- name: Synchronize script files
      synchronize:
        src: /var/ansible-master/roles/pbxs/files/production/
        dest: /var/script/production/
        recursive: yes
      # Set permissions for the files after synchronizing
      become: yes
      become_user: root
      mode: "0755"



# Notes
'
the variable scopes
`{{hostvars['web2'].dns_server }}'

Magic Variables - hostvars to use some host var in another one
another one - groups returen all host under this group

all the information ansbile geting from the hosts called FACTS in ansible

when we use in plybook
- name: test 
   hosts: all
   tasks:
    - debug:
         vars: ansible_facts
here we can get all the hosts details CPU RAM OS System Arch etc
if you don't wont to get the system facts you can spicify this opetion by adding 
gather_facts: no   -> unders hosts   can be also from main config file of ansible 
gathering  = implicit

ansible playbook
all writen on yaml file

playbook is a set of dictionary 
hosts should be identifie in inventory

how to verify the playbook
check mode with --check
ext of check mode 
ansible-playbook --check
then you will the result if you run in real way

diff mode use to see before and after run 
ansible-playbook --diff

use both can be
ansible-playbook --check --diff

to check error
ansible-playbook --sayntax-check

ansible conditionals

ansible modules
system --- user group hostname make etc
command -- command raw script shell
files   ---- acl archive copy replace find etc
database  ---  mongo mysql etc
cloud ---- amazon azure etc
windows ---- win_copy etc
##############################################
'

sudo yum install jq -y
systemctl status httpd
#find /etc -name 'httpd.conf'

cd /etc/httpd/conf
sudo vi /etc/httpd/conf/firewall_api.conf
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteRule ^/firewall/(trust|untrust)$ http://localhost:5000/firewall/$1 [P]
</IfModule>

sudo systemctl restart httpd

vim /var/www/cgi-bin/firewall_api.sh
###############################################################
#!/bin/bash

echo "Content-type: application/json"
echo ""

# Parse JSON input
read -r CONTENT

# Extract the value of ip_or_dns from JSON
IP_OR_DNS=$(echo "$CONTENT" | jq -r '.ip_or_dns')

# Check if the IP/DNS is provided
if [ -z "$IP_OR_DNS" ]; then
    echo '{"error": "Missing ip_or_dns parameter"}'
    exit 1
fi

# Check if the request is for trust or untrust
if [[ $REQUEST_URI == *"/trust" ]]; then
    # Run the fwconsole firewall trust command
    fwconsole firewall trust "$IP_OR_DNS"
    echo '{"message": "IP/DNS trusted"}'
else
    # Run the fwconsole firewall untrust command
    fwconsole firewall untrust "$IP_OR_DNS"
    echo '{"message": "IP/DNS untrusted"}'
fi
###############################################################
sudo systemctl restart httpd

chmod +x /var/www/cgi-bin/firewall_api.sh
systemctl restart httpd
systemctl status httpd
curl -X POST -H "Content-Type: application/json" -d '{"ip_or_dns": "www.google.com"}' https://144.202.46.13/cgi-bin/firewall_api.sh/trust
curl -X POST -H "Content-Type: application/json" -d '{"ip_or_dns": "www.google.com"}' https://144.202.42.215/cgi-bin/firewall_api.sh/untrust
curl "https://api.vultr.com/v2/snapshots/create-from-url" \
  -X POST \
  -H "Authorization: Bearer ${VULTR_API_KEY}" \
  -H "Content-Type: application/json" \
  --data '{
    "url" : "https://example.com/disk_image.raw",
    "description" : "test Snapshot",
    "uefi": "no"
  }'


  curl "https://api.vultr.com/v2/instances" \
  -X POST \
  -H "Authorization: Bearer ${VULTR_API_KEY}" \
  -H "Content-Type: application/json" \
  --data '{
    "region" : "ewr",
    "plan" : "vc2-6c-16gb",
    "label" : "Example Instance",
    "os_id" : 215,
    "user_data" : "QmFzZTY0IEV4YW1wbGUgRGF0YQ==",
    "backups" : "enabled",
    "hostname": "my_hostname",
    "tags": [
      "a tag",
      "another"
    ]
  }'


  curl "https://api.vultr.com/v2/snapshots/{snapshot-id}" \
  -X GET \
  -H "Authorization: Bearer O77SXP4MACSGHBVAEDCATYUJFR2VCITCWR2A}"


  curl "https://api.vultr.com/v2/snapshots" \
  -X POST \
  -H "Authorization: Bearer O77SXP4MACSGHBVAEDCATYUJFR2VCITCWR2A" \
  -H "Content-Type: application/json" \
  --data '{
    "instance_id" : "0c098c73-8433-46b4-b41d-229211ab2fed",
    "description" : "Ansible API test Snapshot"
  }'



  curl "https://api.vultr.com/v2/snapshots" \
  -X GET \
  -H "Authorization: Bearer ${O77SXP4MACSGHBVAEDCATYUJFR2VCITCWR2A}"

  curl "https://api.vultr.com/v2/instances/0c098c73-8433-46b4-b41d-229211ab2fed/vpcs" -X GET -H "Authorization: Bearer O77SXP4MACSGHBVAEDCATYUJFR2VCITCWR2A" 

curl "https://api.vultr.com/v2/snapshots" -X GET -H "Authorization: Bearer ${O77SXP4MACSGHBVAEDCATYUJFR2VCITCWR2A}"

curl "https://api.vultr.com/v2/snapshots" -X POST -H "Authorization: Bearer O77SXP4MACSGHBVAEDCATYUJFR2VCITCWR2A" -H "Content-Type: application/json" --data "{\"instance_id\": \"0c098c73-8433-46b4-b41d-229211ab2fed\", \"description\": \"Ansible API test Snapshot\"}"

# WinRM Ansible 5977

# Configuring HTTPS listener in Windows:

#Step1: Create Certificate
New-SelfSignedCertificate -DnsName "app-01-ringoapp.ringopbx.com" -CertStoreLocation Cert:\LocalMachine\My

#Step2:
#Whitelist port 5985(winrm-http) and 5986(winrm-https) in the security group of the the windows server.
#Step3: Create HTTPS Listener

winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname="app-01-ringoapp.ringopbx.com"; CertificateThumbprint="0B4155E1B2BFFC41055B0DB93980EA909E8D351A"; Port="5977"}'

#Step4:
#Add  new firewall rule for 5986
netsh advfirewall firewall add rule name="Windows Remote Management (HTTPS-In)" dir=in action=allow protocol=TCP localport=5977

#Step5:
#Check the listener and make sure https listener is there.
winrm e winrm/config/Listener


#Check The Service
winrm get winrm/config
#Make sure the Basic Auth is set to true, if not then execute below commands.
Set-Item -Force WSMan:\localhost\Service\auth\Basic $true


#update the port 
winrm set winrm/config/listener?Address=*+Transport=HTTPS '@{Port="5977"}'

# Delete listnere
winrm delete winrm/config/Listener?Address=*+Transport=HTTPS


New-SelfSignedCertificate -DnsName "app-03-ringoapi.ringopbx.com" -CertStoreLocation Cert:\LocalMachine\My
winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname="app-03-ringoapi.ringopbx.com"; CertificateThumbprint="0B4155E1B2BFFC41055B0DB93980EA909E8D351A"; Port="5977"}'
netsh advfirewall firewall add rule name="Windows Remote Management (HTTPS-In)" dir=in action=allow protocol=TCP localport=5977
winrm e winrm/config/Listener
winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
