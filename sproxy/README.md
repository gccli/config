# Sync cert and key to remote

    ./sync.sh <remote-ip>


# Install automatic

1. add `ip hostname` to /etc/hosts

ansible-playbook -i hosts --ask-vault-pass setup.yml
