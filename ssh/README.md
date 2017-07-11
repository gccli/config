# SSH Login Without Password

1) Use `ssh-keygen` creates the public and private keys.

2) Copy the public key to remote-host using `ssh-copy-id`

以下例子将已生成好的rsa public key拷到本机virtualbox启的虚拟机上，将2222端口映射到虚拟机的22端口

    $ ssh-copy-id -i ~/core/.ssh/id_rsa.pub -p 2222 lijing@localhost
    $ ssh -p 2222' lijing@localhost



# 在首次登录时启动ssh-agent

1) 假设已生成好rsa key于~/.ssh目录下

2) 将agentrc文件拷入~/.ssh目录下，在~/.bashrc文件中增加一行

    . ~/.ssh/agentrc
