#!/bin/bash

agent_package_url="https://vstsagentpackage.azureedge.net/agent/3.230.0/vsts-agent-linux-x64-3.230.0.tar.gz"
deploymentgroup_name=$1
az_org_url_path=$2
project_name=$3
az_devops_pat=$4

install_user="vagrant"
tags="dev,vagrant"
agent_path="/opt/azagent"

sudo mkdir $agent_path && \
cd $agent_path && \
sudo curl -fkSL -o vstsagent.tar.gz $agent_package_url && \
sudo tar -zxvf vstsagent.tar.gz >/dev/null 2>&1 && \
sudo chown -R $install_user:$install_user $agent_path;

if [ -x "$(command -v systemctl)" ];
then
    echo -e "\n********* Running as service *********\n";
sudo -i -u $install_user bash << EOF
    ls -la
    echo -e "\n********* Running as $install_user *********\n";
    cd $agent_path
    ls -la
    ./config.sh --deploymentgroup \
        --deploymentgroupname $deploymentgroup_name \
        --addDeploymentGroupTags \
        --deploymentGroupTags $tags \
        --unattended \
        --acceptteeeula \
        --agent $HOSTNAME \
        --url $az_org_url_path \
        --work _work \
        --projectname $project_name \
        --runasservice \
        --auth pat \
        --token $az_devops_pat;
EOF
    sudo ./svc.sh install;
    sudo ./svc.sh start;
fi
