#!/bin/bash
set -e
pushd `dirname $0` > /dev/null;DIR=`pwd -P`;popd > /dev/null
cd ${DIR}
wget -O ${DIR}/portable-ansible.tar.bz2 https://github.com/ownport/portable-ansible/releases/download/v0.5.0/portable-ansible-v0.5.0-py3.tar.bz2
rm -rf ansible
rm -rf ansible-galaxy
rm -rf ansible-playbook
rm -rf .ansible_library
rm -rf .ansible_collections
rm -rf .ansible_roles
tar -jxf portable-ansible.tar.bz2 && rm portable-ansible.tar.bz2
ln -s ansible ansible-galaxy
ln -s ansible ansible-playbook

python3 ${DIR}/ansible-galaxy collection install ansible.posix
python3 ${DIR}/ansible-galaxy collection install community.general
python3 ${DIR}/ansible-galaxy collection install community.crypto
python3 ${DIR}/ansible-galaxy collection install community.docker
python3 ${DIR}/ansible-galaxy install -r requirements.yml

git add ansible
git add ansible-galaxy
git add ansible-playbook
[[ -d ./.ansible_library ]] && git add ./.ansible_library
[[ -d ./.ansible_collections ]] && git add ./.ansible_collections
[[ -d ./.ansible_roles ]] && git add ./.ansible_roles
