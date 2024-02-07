#!/bin/bash
set -ex
set -o allexport

# cleanup colors from outputs
exec 2> >(sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' >&2)
exec > >(sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g')

pushd `dirname $0` > /dev/null;DIR=`pwd -P`;popd > /dev/null
[[ -f "${DIR}/.env" ]] && source "${DIR}/.env"

export DEBIAN_FRONTEND=noninteractive
export ANSIBLE_NOCOLOR=True
export ANSIBLE_CONFIG=${DIR}/ansible.cfg
export ANSIBLE_STDOUT_CALLBACK=yaml

which envsubst > /dev/null || apt update -qqqy && apt install -qqqy gettext
which pip3 > /dev/null || apt update -qqqy && apt install -qqqy python3-pip
which python3 > /dev/null || apt update -qqqy && apt install -qqqy python3

ANSIBLE_HOST=${ANSIBLE_HOST:-localhost}
if [[ ! -z $ANSIBLE_HOST ]]; then
    if [[ ! -z $ANSIBLE_HOST ]] && [[ $ANSIBLE_HOST != "localhost" ]] && [[ $ANSIBLE_HOST != "127.0.0.1" ]]; then
        ANSIBLE_USER=${ANSIBLE_USER:-root}
        ANSIBLE_HOST=${ANSIBLE_HOST}
        ANSIBLE_CONNECTION=ssh
        export USER_DEVELOPER_UID=${USER_DEVELOPER_UID:-1000}
        export USER_DEVELOPER_USERNAME=${USER_DEVELOPER_USERNAME:-"developer"}
    else
        ANSIBLE_USER=${ANSIBLE_USER:-$USER}
        ANSIBLE_HOST=localhost
        ANSIBLE_CONNECTION=local

        export USER_DEVELOPER_UID=$(id -u ${USER_DEVELOPER_USERNAME:-$USER})
        export USER_DEVELOPER_USERNAME=$(id -nu $USER_DEVELOPER_UID)

        if [[ $USER_DEVELOPER_UID -lt 1000 ]]; then
            if id -nu 1000 > /dev/null; then
                export USER_DEVELOPER_UID=1000
                export USER_DEVELOPER_USERNAME=$(id -nu 1000)
            else
                export USER_DEVELOPER_UID=1000
                export USER_DEVELOPER_USERNAME="developer"    
            fi
        fi
    fi
    mkdir -p "${DIR}/environments/${ANSIBLE_HOST}/group_vars"
    envsubst > "${DIR}/environments/${ANSIBLE_HOST}/hosts" <<CONFIG
[coder_workspace_vm]
${ANSIBLE_HOST} ansible_connection=${ANSIBLE_CONNECTION} ansible_user=${ANSIBLE_USER}
CONFIG

        envsubst > "${DIR}/environments/${ANSIBLE_HOST}/group_vars/coder_workspace_vm.yml" <<CONFIG
developer_username: "{{ lookup('env', 'USER_DEVELOPER_USERNAME') | default('developer', True) }}"
developer_uid: "{{ lookup('env', 'USER_DEVELOPER_UID') | default('1000', True) }}"
developer_password_hash: "{{ lookup('env', 'USER_DEVELOPER_PASSWORD_HASH') | default('', True) }}"
developer_github_accounts: []
developer_authorized_keys: []
github_oauth_token: "{{ lookup('env', 'GITHUB_OAUTH_TOKEN') | default('', True) }}"
CONFIG
fi

#pip3 install -r ${DIR}/requirements.txt
ANSIBLE_HOST_KEY_CHECKING=False python3 ${DIR}/ansible-playbook -i ${DIR}/environments/${ANSIBLE_HOST} ${DIR}/playbook.yml "$@"
