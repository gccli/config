# Sync cert and key to remote

    ./sync.sh <remote-ip>


# Install automatic

```
yum install -y epel-release
yum install -y ansible

ansible-playbook -i hosts --ask-vault-pass setup.yml


# overwrite pre-defined variable
ansible-playbook -i hosts --ask-vault-pass setup.yml -e my_hostname=xx.inetlinux.com

```
