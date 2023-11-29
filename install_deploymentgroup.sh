#!/bin/bash

agent_package_url="https://vstsagentpackage.azureedge.net/agent/3.230.0/vsts-agent-linux-x64-3.230.0.tar.gz"
deploymentgroup_name=$1
az_org_url_path=$2
project_name=$3
az_devops_pat=$4

install_user="ubuntu"
tags="dev,vagrant"

echo "agent_package_url: $agent_package_url"
echo "deploymentgroup_name: $deploymentgroup_name"
echo "az_org_url_path: $az_org_url_path"
echo "project_name: $project_name"
echo "az_devops_pat: $az_devops_pat"

sudo mkdir azagent;
chown -R $install_user:$install_user azagent;
cd azagent;

sudo curl -fkSL -o vstsagent.tar.gz $agent_package_url;
sudo tar -zxvf vstsagent.tar.gz >/dev/null 2>&1;
if [ -x "$(command -v systemctl)" ];
then
    echo "Running as service";

sudo -i -u $install_user bash << EOF
    echo "Running as $install_user";
    cd "/home/vagrant/azagent"
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
else
    echo "Running as script";
    echo "In development ...."
    # ./config.sh \
    #     --deploymentgroup \
    #     --deploymentgroupname "Example-Dg" \
    #     --acceptteeeula \
    #     --agent $HOSTNAME \
    #     --url https://dev.azure.com/RecursiveDeveloper/ \
    #     --work _work \
    #     --projectname 'Simple-Express-Server';
    # ./run.sh;
fi
