#! /bin/bash

# ChangeList
#
# 1.5.3 optimize cc-mode of emacs
# 1.5.4 more available for linux distribution
# 1.5.5 optimize emacs config and ssh-agent
# 1.5.6 emacs Tex settings
# 1.5.7 config display variable, more concise config style for bash
#
################################################################################
############            Variables used in this script            ###############
VERSION=1.5.7
config_begin="Generated by config.sh"

opt_timeout=3
opt_link=0
opt_verbose=0
opt_cfg_rsa=0
opt_rsa_without_pass=0
opt_update_emacs=y
if [ -f /etc/redhat-release ]; then
    DISTRIB_ID="CentOS"
    DISTRIB_RELEASE=$(cat /etc/redhat-release|sed 's/CentOS //')
else
    DISTRIB_ID=$(awk '{ print $1 }' /etc/issue)
    DISTRIB_RELEASE=$(lsb_release -r | sed 's/.*:[ \t]*//')
fi

MYLOG=/tmp/config.log.$USER
> $MYLOG
########## END ##########

################################################################################
##################               Functions                  ####################
function die() {
    echo -e "\033[31mError: $1\033[0m"
    exit 1
}
function usage {
    printf "Usage: $0 [ -vh ] [ --rsa ]\n"
    exit 0
}

function err() {
    echo -e "\033[31mError: $1\033[0m" | tee -a $MYLOG
}

function warn() {
    echo -e "\033[33mWarn: $1\033[0m" | tee -a $MYLOG
}

function notice() {
    echo -e "\033[32m$1\033[0m" | tee -a $MYLOG
}

function copyfile() {
    src=$1
    dst=$2
    if [ ! -d $dst ]; then
	rm -f $dst
    else
	rm -f $dst/$(basename $src)
    fi
    if [ $opt_link -ne 0 ]; then
	ln -s $src $dst
    else
	cp -p $src $dst
    fi
}


function check_config() {
    local bashlocal=~/.bash_local
    [ ! -f $bashlocal ] && return

    if grep "agentrc" $bashlocal >/dev/null; then
        [ $opt_cfg_rsa -eq 0 ] && read -p "Re-config bash, really disable ssh-agent (y/n)? " opt_cfg_rsa
    fi
}

function config_bash()
{
    local bashrc=~/.bashrc
    local bashlocal=~/.bash_local

    copyfile $PWD/bash/.functions ~/
    copyfile $PWD/bash/.bash_aliases ~/
    copyfile $PWD/.gdbinit ~/
    copyfile $PWD/.pythonstartup ~/
    copyfile $PWD/.vboxmanage ~/

    mkdir -p ~/.functions.d
    for f in $(ls $PWD/bash/.functions.d); do
        copyfile $PWD/bash/.functions.d/$f ~/.functions.d
    done

    notice "config bash $BASH_VERSION"
    [ ! -f $bashrc ] && die "$bashrc not exists"

    grep "\.bash_local" $bashrc
    if [ $? -ne 0 ]; then
        notice "$bashrc not configured"
        echo ". ~/.bash_local" >> $bashrc
    fi

    echo "# $config_begin @time:$(date +%D) @version:$VERSION" > $bashlocal
    echo ". ~/.functions" >> $bashlocal
    echo ". ~/.vboxmanage" >> $bashlocal

    [ $DISTRIB_ID == "CentOS" ] && echo ". ~/.bash_aliases" >> $bashlocal

    if [ $opt_cfg_rsa -ne 0 ]; then
        echo ". ~/.ssh/agentrc" >> $bashlocal
    fi

    echo >> $bashlocal
    echo "# env variables" >> $bashlocal
    # config python startup file
    echo 'export PYTHONSTARTUP=~/.pythonstartup' >> $bashlocal
    cat $bashlocal
}

function config_git()
{
    which git 2>&1 >/dev/null
    if [ $? -eq 0 ]; then
        notice "config git"

        git config --global core.editor emacs
        git config --global alias.co checkout
        git config --global alias.br branch
        git config --global alias.ci commit
        git config --global alias.st status
        git config --global color.ui true
        git config --global push.default current
        # Cache git password, set the cache to timeout after 1 hour
        git config --global credential.helper 'cache --timeout=3600'

        echo git config --global user.name  '"Jing Li"'
        echo git config --global user.email '"lijing@example.com"'
    fi
}

function config_ssh_agent()
{
    local SRC=$PWD/ssh/id_rsa
    local DST=~/.ssh/id_rsa

    local line=". ~/.ssh/agentrc"
    if [ "${opt_cfg_rsa}x" == "yx" ]; then
        rm -f ~/.ssh/agentrc ~/.ssh/environment
        return
    fi

    if [ "${opt_cfg_rsa}x" != "1x" ]; then
        echo "Ignore SSH agent"
        return
    fi

    if [ ! -f ${SRC} ]; then
        echo
        notice "Decrypting RSA key:"

        local version=$(openssl version | egrep -o '[0-9]\.[0-9]\.[0-9]')
        if [ "${version:0:3}" == "1.1" ]; then
            # The default digest was changed from md5 to sha256 in Openssl 1.1
            openssl aes-256-cbc -md md5 -d -in ${SRC}.bin -out ${SRC}
            [ $? -ne 0 ] && die "Decrypt RSA key error"
        else
            openssl aes-256-cbc -d -in ${SRC}.bin -out ${SRC}
            [ $? -ne 0 ] && die "Decrypt RSA key error"
        fi

        chmod 600 ${SRC}
        if [ $opt_rsa_without_pass -eq 1 ]; then
            notice "Remove passphrase from RSA key:"
            ssh-keygen -p -f ${SRC} -N ""
        fi
    fi

    notice "config ssh agent"
    cp $PWD/ssh/agentrc ~/.ssh/agentrc

    diff $SRC $DST >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        warn "$DST already exists"
    else
        cp -f $SRC $DST && chmod 400 $DST
    fi

    notice "Add ssh public key to ~/.ssh/authorized_keys:"
    ssh-keygen -y -f $DST | tee -a ~/.ssh/authorized_keys
}

function config_ssh_server()
{
    [ $UID -ne 0 ] && echo "use root config sshd" && return

    local svname=ssh
    if [ $DISTRIB_ID == "CentOS" ]; then
        svname=sshd
    fi

    notice "config ssh server"
    grep '^UseDNS' /etc/ssh/sshd_config > /dev/null
    if [ $? -ne 0 ]; then
        echo "UseDNS no" >> /etc/ssh/sshd_config
        service $svname restart
    else
        warn "ssh server already configure"
    fi
}

function config_ssh()
{
    mkdir -p ~/.ssh
    if [ -f ~/.ssh/config ]; then
        cp ~/.ssh/config ~/.ssh/config.$(date +%s)
    fi

    /bin/cp -f ${PWD}/ssh/config ~/.ssh/
    chown ${USER}  ~/.ssh/config
    chmod 400      ~/.ssh/config
    config_ssh_server
    config_ssh_agent
}

########## END ##########

################################################################################
##################           Parse Command Line             ####################
if ! my__options=$(getopt -u -o vhlN -l rsa,rsa-nopass,help -- "$@")
then
    exit 1
fi
set -- $my__options
while [ $# -gt 0 ]
do
    case $1 in
        -h|--help)
            usage;;
        -v)
            opt_verbose=$(($opt_verbose+1));
            shift;;
        -l)
            opt_link=1;;
        --rsa)
            opt_cfg_rsa=1;;
        --rsa-nopass)
            opt_cfg_rsa=1
            opt_rsa_without_pass=1
            ;;
        -N)
            opt_update_emacs=n
            ;;
        (--) shift; break;;
        (-*) echo "error - unrecognized option $1" 1>&2; exit 1;;
        (*) usage;;
    esac
    shift
done
########## END ##########
echo "Customizing for $DISTRIB_ID $DISTRIB_RELEASE" | tee $MYLOG
[ $opt_cfg_rsa -eq 1 ] && echo "  Import RSA Key: yes"
[ $opt_link -ne 0 ] && echo "  Symbol Link: yes"
echo

[ -z "$DISTRIB_ID" ] && die "Cannot get distribution ID"
check_config
config_bash
config_git
./config-emacs.sh ${opt_update_emacs}
config_ssh
echo
echo "source ~/.bashrc"
