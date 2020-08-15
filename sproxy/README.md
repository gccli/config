# Sync cert and key to remote

    ./sync.sh <remote-ip> <domain>


# Install automatic

```
ansible-playbook -i hosts --ask-vault-pass setup.yml

# overwrite pre-defined variable
ansible-playbook -i hosts --ask-vault-pass setup.yml -e my_hostname=xx.inetlinux.com


# only run stunnel
ansible-playbook -i hosts --ask-vault-pass setup.yml --tags=stunnel
```
